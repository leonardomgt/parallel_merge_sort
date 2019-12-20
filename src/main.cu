#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "mpi.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

void merge(int *src, int offset, int leftSize, int rightSize);
void sequentialMergeSort(int *src, int offset, int size);
void parallelMergeSort(int *src, int size, int *result);

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
	bool gpu_mode;

	sscanf(argv[1], "%010x", &base_seed);
	sscanf(argv[2], "%lu", &ds_size);

	gpu_mode = !strcmp(argv[3], "GPU");

	// * Initalize MPI Library
	MPI_Init(&argc, &argv);

	int n_procs, proc_id;
	MPI_Comm_size(MPI_COMM_WORLD, &n_procs);
	MPI_Comm_rank(MPI_COMM_WORLD, &proc_id);

	printf("ID: %d\n", proc_id);

	int *my_array = new int[ds_size];

	if (proc_id == 0)
	{
		double start_generating = MPI_Wtime();

		// * Generate differente seed for each node, such that different numbers are generated.
		srand(base_seed + proc_id);

		// * Generate N pseudo-random integers in the interval [0, RAND_MAX]
		for (size_t i = 0; i < ds_size; i++)
			my_array[i] = rand();

		double end_generating = MPI_Wtime();

		printf("Generating complete in %f s\n\n", end_generating - start_generating);
	}

	double start_exec = MPI_Wtime();

	// * Execute the Parallel Merge Sort algorithm.

	int *merged_array = new int[ds_size];
	parallelMergeSort(my_array, ds_size, merged_array);

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

void parallelMergeSort(int *src, int size, int *result)
{

	int n_procs, proc_id;
	MPI_Comm_size(MPI_COMM_WORLD, &n_procs);
	MPI_Comm_rank(MPI_COMM_WORLD, &proc_id);

	// * Evenly number of values to be sorted per process
	int valuesPerProcess = (size + n_procs - 1) / n_procs;

	int *processPart = new int[valuesPerProcess];

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
		gpuMergeSort(processPart, 0, valuesPerProcess);
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
			// printf("\nId %d sending to %f\n", proc_id, proc_id - pow(2, k - 1));
			MPI_Send(result, countToSend, MPI_INT, proc_id - pow(2, k - 1), k, MPI_COMM_WORLD);
		}
		else if (proc_id % (int)pow(2, k) == 0 && proc_id + pow(2, k - 1) < n_procs)
		{
			// printf("\nId %d receiving from %f\n", proc_id, proc_id + pow(2, k - 1));
			MPI_Recv(result + countToSend, valuesPerProcess * k, MPI_INT, proc_id + pow(2, k - 1), k, MPI_COMM_WORLD, &status);

			int receivedCount;
			MPI_Get_count(&status, MPI_INT, &receivedCount);

			merge(result, 0, countToSend, receivedCount);

			countToSend += receivedCount;
		}
	}
}

void merge(int *src, int offset, int leftSize, int rightSize)
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

void sequentialMergeSort(int *src, int offset, int size)
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

void gpuMergeSort(int *src, int offset, int size){
	printf("blockDim: (%d, %d, %d)", blockDim.x, blockDim.y, blockDim.z);
	printf("gridDim: (%d, %d, %d)", gridDim.x, gridDim.y, gridDim.z);
	
}
