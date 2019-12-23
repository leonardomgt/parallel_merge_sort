#!/bin/bash

# ==============================
#     200.000 entries
# ==============================

sbatch --nodes=1 --gres=gpu:1 -C TitanX main.job 0x1234abcd 1600000 GPU
sbatch --nodes=1 --gres=gpu:1 -C TitanX main.job 0x10203040 1600000 GPU
sbatch --nodes=1 --gres=gpu:1 -C TitanX main.job 0x40e8c724 1600000 GPU
sbatch --nodes=1 --gres=gpu:1 -C TitanX main.job 0x79cbba1d 1600000 GPU
sbatch --nodes=1 --gres=gpu:1 -C TitanX main.job 0xac7bd459 1600000 GPU

sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0x1234abcd 1600000 GPU
sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0x10203040 1600000 GPU
sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0x40e8c724 1600000 GPU
sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0x79cbba1d 1600000 GPU
sbatch --nodes=2 --gres=gpu:1 -C TitanX main.job 0xac7bd459 1600000 GPU

sbatch --nodes=4 --gres=gpu:1 -C TitanX main.job 0x1234abcd 1600000 GPU
sbatch --nodes=4 --gres=gpu:1 -C TitanX main.job 0x10203040 1600000 GPU
sbatch --nodes=4 --gres=gpu:1 -C TitanX main.job 0x40e8c724 1600000 GPU
sbatch --nodes=4 --gres=gpu:1 -C TitanX main.job 0x79cbba1d 1600000 GPU
sbatch --nodes=4 --gres=gpu:1 -C TitanX main.job 0xac7bd459 1600000 GPU

sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0x1234abcd 1600000 GPU
sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0x10203040 1600000 GPU
sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0x40e8c724 1600000 GPU
sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0x79cbba1d 1600000 GPU
sbatch --nodes=8 --gres=gpu:1 -C TitanX main.job 0xac7bd459 1600000 GPU

sbatch --nodes=16 --gres=gpu:1 -C TitanX main.job 0x1234abcd 1600000 GPU
sbatch --nodes=16 --gres=gpu:1 -C TitanX main.job 0x10203040 1600000 GPU
sbatch --nodes=16 --gres=gpu:1 -C TitanX main.job 0x40e8c724 1600000 GPU
sbatch --nodes=16 --gres=gpu:1 -C TitanX main.job 0x79cbba1d 1600000 GPU
sbatch --nodes=16 --gres=gpu:1 -C TitanX main.job 0xac7bd459 1600000 GPU


squeue