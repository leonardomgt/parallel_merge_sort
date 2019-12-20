#!/bin/bash
sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0x1234abcd 200000 GPU
squeue
