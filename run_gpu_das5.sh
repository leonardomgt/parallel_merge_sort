#!/bin/bash
sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0x1234abcd 200000 GPU
squeue
