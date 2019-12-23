#!/bin/bash

# ==============================
#     80.000.000 entries
# ==============================

sbatch --nodes=1 main.job 0x1234abcd 80000000 CPU
sbatch --nodes=1 main.job 0x10203040 80000000 CPU
sbatch --nodes=1 main.job 0x40e8c724 80000000 CPU
sbatch --nodes=1 main.job 0x79cbba1d 80000000 CPU
sbatch --nodes=1 main.job 0xac7bd459 80000000 CPU

sbatch --nodes=2 main.job 0x1234abcd 80000000 CPU
sbatch --nodes=2 main.job 0x10203040 80000000 CPU
sbatch --nodes=2 main.job 0x40e8c724 80000000 CPU
sbatch --nodes=2 main.job 0x79cbba1d 80000000 CPU
sbatch --nodes=2 main.job 0xac7bd459 80000000 CPU

sbatch --nodes=4 main.job 0x1234abcd 80000000 CPU
sbatch --nodes=4 main.job 0x10203040 80000000 CPU
sbatch --nodes=4 main.job 0x40e8c724 80000000 CPU
sbatch --nodes=4 main.job 0x79cbba1d 80000000 CPU
sbatch --nodes=4 main.job 0xac7bd459 80000000 CPU

sbatch --nodes=8 main.job 0x1234abcd 80000000 CPU
sbatch --nodes=8 main.job 0x10203040 80000000 CPU
sbatch --nodes=8 main.job 0x40e8c724 80000000 CPU
sbatch --nodes=8 main.job 0x79cbba1d 80000000 CPU
sbatch --nodes=8 main.job 0xac7bd459 80000000 CPU

sbatch --nodes=16 main.job 0x1234abcd 80000000 CPU
sbatch --nodes=16 main.job 0x10203040 80000000 CPU
sbatch --nodes=16 main.job 0x40e8c724 80000000 CPU
sbatch --nodes=16 main.job 0x79cbba1d 80000000 CPU
sbatch --nodes=16 main.job 0xac7bd459 80000000 CPU

squeue