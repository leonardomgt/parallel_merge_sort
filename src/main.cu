#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "mpi.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <helper_cuda.h>


void merge(int *src, ulong offset, ulong leftSize, ulong rightSize);
void sequentialMergeSort(int *src, ulong offset, ulong size);
void parallelMergeSort(int *src, ulong size, int *result, bool gpu_mode);
__global__ void gpuMergeSort(int *src, int *dest, ulong size, ulong threadPartSize, int nSlices, int threadsPerBlock, int blocksPerGrid);
__device__ void gpuMerge(int* src, int* dest, ulong it_left, ulong it_middle, ulong it_right);
// * Create new MPI datatype: MPI_EDGE
MPI_Datatype create_chunk_MPI_datatype();

struct chunk {
	int* data;
	ulong size;
};

int main(int argc, char **argv)
{

	// * Check arguments
	if (argc != 4)
	{
		fprintf(stderr, "usage: %s <random_seed> <dataset_size> <execution_mode:'GPU/CPU'>\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	int base_seed;
	ulong ds_size;

	sscanf(argv[1], "%010x", &base_seed);
	sscanf(argv[2], "%lu", &ds_size);

	bool gpu_mode = !strcmp(argv[3], "GPU");

	// * Initalize MPI Library
	MPI_Init(&argc, &argv);

	int n_procs, proc_id;
	MPI_Comm_size(MPI_COMM_WORLD, &n_procs);
	MPI_Comm_rank(MPI_COMM_WORLD, &proc_id);

	//printf("ID: %d\n", proc_id);
	printf("First alocation: %d...", proc_id);
	int *my_array = new int[ds_size];
	printf(" DONE\n");

	if (proc_id == 0)
	{

		printf("Parallel Merge Sort\n\n");
		printf("Random seed: %s\n", argv[1]);
		printf("Data size: %s\n", argv[2]);
		printf("Execution mode: %s\n\n", gpu_mode ? "CPU + GPU" : "CPU");
		printf("Number of CPU nodes: %d\n", n_procs);
		

		double start_generating = MPI_Wtime();

		// * Generate differente seed for each node, such that different numbers are generated.
		srand(base_seed + proc_id);

		// * Generate N pseudo-random integers in the interval [0, RAND_MAX]
		for (size_t i = 0; i < ds_size; i++)
			my_array[i] = rand();

		double end_generating = MPI_Wtime();

		printf("Generating complete in %f s\n", end_generating - start_generating);
	}

	double start_exec = MPI_Wtime();

	// * Execute the Parallel Merge Sort algorithm.

	int *merged_array = new int[ds_size];
	parallelMergeSort(my_array, ds_size, merged_array, gpu_mode);

	double end_exec = MPI_Wtime();


	if (proc_id == 0)
	{
		printf("Execution complete in %f s\n", end_exec - start_exec);

		printf("\n\nSorted array...\n\n");

		for (ulong i = 0; i < ds_size; i += (ds_size / 20 + 1))
		{
			printf("i: %lu, v: %d\n", i, merged_array[i]);
		}
	}

	MPI_Finalize();
	return 0;
}

void parallelMergeSort(int *src, ulong size, int *result, bool gpu_mode)
{

	int n_procs, proc_id;
	MPI_Comm_size(MPI_COMM_WORLD, &n_procs);
	MPI_Comm_rank(MPI_COMM_WORLD, &proc_id);

	// * Evenly number of values to be sorted per process
	printf("SIZE: %lu\n", size);
	printf("n_procs: %d\n", n_procs);
	printf("size + n_procs - 1: %lu\n", size + n_procs - 1);
	printf("valuesPerProcess: %lu\n", (size + n_procs - 1) / n_procs);
	ulong valuesPerProcess = ((size + n_procs - 1) / n_procs);
	
	printf("Third alocation: %d... valuesPerProcess: %lu", proc_id, valuesPerProcess);
	int *processPart = new int[valuesPerProcess];
	printf(" DONE\n");

	// TODO: Use MPI_Scatterv to distribute the values more evenly

	MPI_Scatter(
		src,
		valuesPerProcess, MPI_INT,
		processPart,
		valuesPerProcess, MPI_INT,
		0, MPI_COMM_WORLD);

	// * Adjust valuesPerProcess for the last process.
	if (proc_id == n_procs - 1 && size % valuesPerProcess != 0)
	{
		valuesPerProcess = size % valuesPerProcess;
	}


	if(gpu_mode){
		// TODO: GPU Parallelization 

		// * Calculate threadsPerBlock and blocksPerGrid
		int threadsPerBlock;  
		int minBlocksPerGrid; 
						
		int blocksPerGrid;

		cudaOccupancyMaxPotentialBlockSize(&minBlocksPerGrid, &threadsPerBlock,	gpuMergeSort);

		blocksPerGrid = (valuesPerProcess + threadsPerBlock - 1) / threadsPerBlock;

		// * Allocate and copy data to GPU shared memory
		int *gpuData, *gpuResult;


		checkCudaErrors(cudaMalloc((void**) &gpuData, valuesPerProcess * sizeof(int)));
		checkCudaErrors(cudaMalloc((void**) &gpuResult, valuesPerProcess * sizeof(int)));

		checkCudaErrors(cudaMemcpy(gpuData, processPart, valuesPerProcess * sizeof(int), cudaMemcpyHostToDevice));

		int *gpuInput = gpuData, *gpuOutput = gpuResult;

		long nThreads = threadsPerBlock * blocksPerGrid;

		for (int valuesPerThread = 2; valuesPerThread < (size << 1); valuesPerThread <<= 1) {
			ulong nSlices = size / ((nThreads) * valuesPerThread) + 1;
	
			gpuMergeSort<<<blocksPerGrid, threadsPerBlock>>>(gpuInput, gpuOutput, valuesPerProcess, valuesPerThread, nSlices, threadsPerBlock, blocksPerGrid);
	
	
			// Swap input and output pointers for next iteration
			gpuInput = gpuInput == gpuData ? gpuResult : gpuData;
			gpuOutput = gpuOutput == gpuData ? gpuResult : gpuData;
		}
		
		checkCudaErrors(cudaMemcpy(processPart, gpuData, valuesPerProcess * sizeof(long), cudaMemcpyDeviceToHost));

		checkCudaErrors(cudaFree(gpuInput));
		checkCudaErrors(cudaFree(gpuOutput));
		// gpuMergeSort<<<blocksPerGrid, threadsPerBlock>>>(processPart, nThreads, valuesPerProcess);
	}
	else{
		sequentialMergeSort(processPart, 0, valuesPerProcess);
	}

	memcpy(result, processPart, valuesPerProcess * sizeof(int));

	int countToSend = valuesPerProcess;

	MPI_Status status;

	for (size_t k = 1; k <= ceil(log2(n_procs)); k++)
	{
		if (proc_id % (int)pow(2, k) == pow(2, k - 1))
		{
			// printf("\nId %d sending %d values to %f\n", proc_id, countToSend, proc_id - pow(2, k - 1));
			MPI_Send(result, countToSend, MPI_INT, proc_id - pow(2, k - 1), k, MPI_COMM_WORLD);
		}
		else if (proc_id % (int)pow(2, k) == 0 && proc_id + pow(2, k - 1) < n_procs)
		{
			// printf("\nId %d receiving %d values from %f\n", proc_id, valuesPerProcess * (int)pow(2, k), proc_id + pow(2, k - 1));
			MPI_Recv(result + countToSend, valuesPerProcess * (int)pow(2, k), MPI_INT, proc_id + pow(2, k - 1), k, MPI_COMM_WORLD, &status);

			int receivedCount;
			MPI_Get_count(&status, MPI_INT, &receivedCount);

			merge(result, 0, countToSend, receivedCount);

			countToSend += receivedCount;
		}
	}
}

void merge(int *src, ulong offset, ulong leftSize, ulong rightSize)
{

	int *left = new int[leftSize];
	int *right = new int[rightSize];

	memcpy(left, src + offset, leftSize * sizeof(int));
	memcpy(right, src + offset + leftSize, rightSize * sizeof(int));

	int it_left = 0, it_right = 0, it_res = offset;

	while (it_left < leftSize && it_right < rightSize)
	{
		if (left[it_left] < right[it_right])
		{
			src[it_res] = left[it_left];
			it_left++;
		}
		else
		{
			src[it_res] = right[it_right];
			it_right++;
		}
		it_res++;
	}

	while (it_left < leftSize)
	{
		src[it_res] = left[it_left];
		it_left++;
		it_res++;
	}

	while (it_right < rightSize)
	{
		src[it_res] = right[it_right];
		it_right++;
		it_res++;
	}
}

void sequentialMergeSort(int *src, ulong offset, ulong size)
{
	if (size > 1)
	{
		int leftSize = size / 2;
		int rightSize = size - leftSize;

		sequentialMergeSort(src, offset, leftSize);
		sequentialMergeSort(src, offset + leftSize, rightSize);

		merge(src, offset, leftSize, rightSize);
	}
}

__global__
void gpuMergeSort(int *src, int *dest, ulong size, ulong threadPartSize, int nSlices, int threadsPerBlock, int blocksPerGrid)
{
	int threadIndex = blockIdx.x * blockDim.x + threadIdx.x;

	ulong it_left = threadPartSize * threadIndex * nSlices;
	ulong it_middle, it_right;

    for (long si = 0; si < nSlices; si++) {
		if (it_left >= size)
			break;

		it_middle = min(it_left + (threadPartSize >> 1), size);
		it_right = min(it_left + threadPartSize, size);

		gpuMerge(src, dest, it_left, it_middle, it_right);
		it_left += threadPartSize;
	}
}

__device__ 
void gpuMerge(int* src, int* dest, ulong it_left, ulong it_middle, ulong it_right) {
    ulong i = it_left;
    ulong j = it_middle;
    for (ulong k = it_left; k < it_right; k++) {
        if (i < it_middle && (j >= it_right || src[i] < src[j])) {
            dest[k] = src[i];
            i++;
        } else {
            dest[k] = src[j];
            j++;
        }
    }
}