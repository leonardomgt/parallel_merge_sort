#!/bin/bash
sbatch --nodes=4 main.job 0x1234abcd 1600000 CPU
squeue