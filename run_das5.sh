#!/bin/bash
sbatch --nodes=2 main.job 0x1234abcd 200000
squeue