#!/bin/bash
# Written by Keith Harrigian / Nathaniel Weir

## Choose Port
PORT=6000

## Choose Path for Running the Noteboook and storing the job log
## Default is the current directory
NB_LOC="${PWD}"
GL="${NB_LOC}/logs"
mkdir -p "${GL}"

## Get Current Date for Logs
DATE=`date '+%Y-%m-%d-%H-%M-%S'`

## Log files
ERRFILE="${GL}notebook_${DATE}.out"

## Schedule the Job
sub_message=$(qsub -V -j y -o ${ERRFILE} "run_notebook.sh" ${PORT} ${NB_LOC})
job_id=$(echo ${sub_message} | awk '{print $3}')

## Wait For Job to Start Running
job_status=$(qstat | grep ${job_id} | awk '{print $5}')
while [[ ${job_status} != "r" ]]
do
    qstat | grep ${job_id}
    sleep 5
    job_status=$(qstat | grep ${job_id} | awk '{print $5}')
done

## Sleep a bit To Let The Notebook Start Up
echo "Letting the notebook startup..."
sleep 5

## Identify Node Where Job is Running
node_address=$(qstat -u $USER | grep ${job_id} | awk '{print $8}')
node_address=${node_address#*@}
node_address=${node_address%%.*}

## Where is the Job Running
echo "Job Running on ${node_address}"

## Open SSH Tunnel
ssh -o "StrictHostKeyChecking=no" -Nf -L ${PORT}:localhost:${PORT} ${node_address}
status=$?
if [ $status -ne 0 ]
then
    echo "Port forwarding from ${node_address}:{$PORT} failed. Check active processes with ps aux | grep ${USER[1:5]} "
fi


## Alert User
usr_alert="On local machine, run: ssh -L ${PORT}:localhost:${PORT} ${USER}@login.clsp.jhu.edu"
echo ${usr_alert}
