#!/bin/bash

# ==============================
#     1.600.000 entries
# ==============================

sbatch --nodes=1 main.job 0x1234abcd 1600000
sbatch --nodes=1 main.job 0x10203040 1600000
sbatch --nodes=1 main.job 0x40e8c724 1600000
sbatch --nodes=1 main.job 0x79cbba1d 1600000
sbatch --nodes=1 main.job 0xac7bd459 1600000

sbatch --nodes=2 main.job 0x1234abcd 1600000
sbatch --nodes=2 main.job 0x10203040 1600000
sbatch --nodes=2 main.job 0x40e8c724 1600000
sbatch --nodes=2 main.job 0x79cbba1d 1600000
sbatch --nodes=2 main.job 0xac7bd459 1600000

sbatch --nodes=4 main.job 0x1234abcd 1600000
sbatch --nodes=4 main.job 0x10203040 1600000
sbatch --nodes=4 main.job 0x40e8c724 1600000
sbatch --nodes=4 main.job 0x79cbba1d 1600000
sbatch --nodes=4 main.job 0xac7bd459 1600000

sbatch --nodes=8 main.job 0x1234abcd 1600000
sbatch --nodes=8 main.job 0x10203040 1600000
sbatch --nodes=8 main.job 0x40e8c724 1600000
sbatch --nodes=8 main.job 0x79cbba1d 1600000
sbatch --nodes=8 main.job 0xac7bd459 1600000

sbatch --nodes=16 main.job 0x1234abcd 1600000
sbatch --nodes=16 main.job 0x10203040 1600000
sbatch --nodes=16 main.job 0x40e8c724 1600000
sbatch --nodes=16 main.job 0x79cbba1d 1600000
sbatch --nodes=16 main.job 0xac7bd459 1600000

squeue