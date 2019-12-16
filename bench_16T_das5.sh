#!/bin/bash

# ==============================
#     16.000.000.000 entries
# ==============================

sbatch --nodes=1 main.job 0x1234abcd 16000000000
sbatch --nodes=1 main.job 0x10203040 16000000000
sbatch --nodes=1 main.job 0x40e8c724 16000000000
sbatch --nodes=1 main.job 0x79cbba1d 16000000000
sbatch --nodes=1 main.job 0xac7bd459 16000000000

sbatch --nodes=2 main.job 0x1234abcd 16000000000
sbatch --nodes=2 main.job 0x10203040 16000000000
sbatch --nodes=2 main.job 0x40e8c724 16000000000
sbatch --nodes=2 main.job 0x79cbba1d 16000000000
sbatch --nodes=2 main.job 0xac7bd459 16000000000

sbatch --nodes=4 main.job 0x1234abcd 16000000000
sbatch --nodes=4 main.job 0x10203040 16000000000
sbatch --nodes=4 main.job 0x40e8c724 16000000000
sbatch --nodes=4 main.job 0x79cbba1d 16000000000
sbatch --nodes=4 main.job 0xac7bd459 16000000000

sbatch --nodes=8 main.job 0x1234abcd 16000000000
sbatch --nodes=8 main.job 0x10203040 16000000000
sbatch --nodes=8 main.job 0x40e8c724 16000000000
sbatch --nodes=8 main.job 0x79cbba1d 16000000000
sbatch --nodes=8 main.job 0xac7bd459 16000000000

sbatch --nodes=16 main.job 0x1234abcd 16000000000
sbatch --nodes=16 main.job 0x10203040 16000000000
sbatch --nodes=16 main.job 0x40e8c724 16000000000
sbatch --nodes=16 main.job 0x79cbba1d 16000000000
sbatch --nodes=16 main.job 0xac7bd459 16000000000

squeue