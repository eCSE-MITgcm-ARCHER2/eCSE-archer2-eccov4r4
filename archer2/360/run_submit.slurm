#!/bin/bash
# Slurm job options (job-name, compute nodes, job time)
# are set outside this script to allow easy changes and testing.


#SBATCH --cpus-per-task=1

# Replace [budget code] below with your project code (e.g. t01)

#SBATCH --account=ecseab06-guest 

#SBATCH --export=none


# Setup the job environment (this module needs to be loaded before any other modules)

. ../scripts/case_setup
. rundef.sh

cat rundef.sh

if [[ "x"${ECCO_UCX} != "x" ]]
then
echo turn on UCX
module swap craype-network-ofi craype-network-ucx
module swap cray-mpich cray-mpich-ucx
fi


module list
ftn --version

# Set the number of threads to 1

#   This prevents any threaded system libraries from automatically 
#   using threading.

export OMP_NUM_THREADS=1



# Launch the parallel job

#   srun picks up the distribution from the sbatch options

SRUNOPTS="--distribution=${ECCO_SRUND} --hint=nomultithread"
timestart="$(date +%s)"

echo srun $SRUNOPTS $ECCO_EXE
srun $SRUNOPTS $ECCO_EXE
timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"

echo Run-time seconds $elapsedtotal
echo Run-time seconds $elapsedtotal > times

OUTTAIL=$(tail -1 STDOUT.0000)
if [[ ${OUTTAIL} == "PROGRAM MAIN: Execution ended Normally" ]]
then  
       	isok="ok"
else  
	isok=$OUTTAIL
fi

tracesummary1="| $SLURM_JOB_ID | $SLURM_JOB_NAME | $SLURM_JOB_NUM_NODES | $SLURM_JOB_QOS | $SLURM_JOB_CPUS_PER_NODE | $SLURM_TASKS_PER_NODE "
	traces2=" | $ECCO_SRUND | $MITGCM_FFLAGS $MITGCM_GENM_FLAGS | $elapsedtotal | $isok |"
tracesummary=${tracesummary1}${traces2}

echo $tracesummary
echo $tracesummary > traceSummary.txt

../scripts/ecse_ecco_check.sh > eec.txt

echo xthi

# get some info on placement and memory used  - optional extras.
module load xthi
srun  $SRUNOPTS xthi > placement_xthi.txt
cat placement_xthi.txt

