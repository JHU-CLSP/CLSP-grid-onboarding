#!/bin/bash
#$ -cwd -V
#$ -N notebook
#$ -l 'mem_free=10G,ram_free=10G'

## Activate Conda Environment
source activate onboarding

## Start Jupyter Server
jupyter notebook --no-browser --port=${1} --NotebookApp.max_buffer_size=64000000000 --notebook-dir=${2}

