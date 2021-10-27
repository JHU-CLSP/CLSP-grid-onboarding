#!/bin/bash

#$ -cwd -V  # Send your environment variables to the compute node
#$ -N url-count  # Name of the job
#$ -j y -o $JOB_NAME-$JOB_ID.out  # Name of the log file
#$ -M aadelucia@jhu.edu  # Put your email here
# #$ -m b  # Email notification for job start
# #$ -m e  # Email notification for job end (NEVER USE THIS FOR JOB ARRAYS YOU WILL GET AN EMAIL FOR EACH SUB-JOB)
#$ -l ram_free=5G,mem_free=5G  # How much memory we request from the compute node
# #$ -pe smp 10  # How many processes our job will spawn. The allocated resources (-l) are PER PROCESS
#$ -t 1-100  # How many tasks in our job array. Access task ID with $SGE_TASK_ID

# Set environment variables like conda environment
conda activate minerva-proj
INPUT_DIR="/home/aadelucia/files/minerva/raw_tweets_deduplicated/tweets"
OUTPUT_DIR=""

# Get list of all files in the directory
INPUT_FILES=(${INPUT_DIR}/*.gz)

# Call your script and pass the subset of files assigned to this task
STEP=870  # 86,725 files / 100 tasks = ~870 files per task
START_INDEX=$[(SGE_TASK_ID - 1) * STEP]
# Access array subset for this task with ${INPUT_FILES[@]:$START_INDEX:$STEP}
echo "Started files ${START_INDEX} TO $[START_INDEX + STEP]..."

python analyze_tweet_urls.py \
    --input-files ${INPUT_FILES} \
    --output-dir "${OUTPUT_DIR}" \

# Check exit status of task
status=$?
if [ $status -ne 0 ]
then
    echo "Task $SGE_TASK_ID failed"
    exit 1
fi

# Use the last task to "reduce" the output
if [ ${SGE_TASK_ID} -eq ${SGE_TASK_LAST} ]
then
    # Ensure that last task ID is the last task to finish
    while [ $(qstat -u $USER | grep ${JOB_ID} | wc -l) -ne 1 ]
    do
        # Wait patiently
        sleep 20
    done

    python analyze_tweet_urls.py \
      --input-files ${INPUT_FILES} \
      --output-dir "${OUTPUT_DIR}" \
      --aggregate

    echo "Done"
fi

