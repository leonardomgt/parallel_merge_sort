#!/bin/bash
sbatch --nodes=2 main.job 0x1234abcd 16000000000 CPU
squeue