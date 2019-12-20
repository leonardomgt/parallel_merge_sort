#!/bin/bash
sbatch --nodes=1 main.job 0x1234abcd 200000 CPU
squeue