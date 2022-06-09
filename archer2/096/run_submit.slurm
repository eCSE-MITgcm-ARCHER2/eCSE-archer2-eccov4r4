#!/bin/bash
# Slurm job options (job-name, compute nodes, job time)
# are set outside this script to allow easy changes and testing.


#SBATCH --cpus-per-task=1

# Replace [budget code] below with your project code (e.g. t01)

#SBATCH --account=[budget code]

#SBATCH --export=none


# Setup the job environment (this module needs to be loaded before any other modules)

. ../scripts/case_setup
module list
ftn --version

# Set the number of threads to 1

#   This prevents any threaded system libraries from automatically 
#   using threading.

export OMP_NUM_THREADS=1



# Launch the parallel job

#   srun picks up the distribution from the sbatch options

timestart="$(date +%s)"

echo srun --distribution=block:cyclic --hint=nomultithread ./mitgcmuv
srun --distribution=block:cyclic --hint=nomultithread ./mitgcmuv

# Below is just to capture the run details into a file tracesummary.txt

timeend="$(date +%s)"
elapsedtotal="$(expr $timeend - $timestart)"
echo Run end `date` 
echo Run-time seconds $elapsedtotal

stdo=STDOUT.0000
x=$(stat --format=%z $stdo)

tracesummary1="| ${x:0:16} | $SLURM_JOB_ID | $SLURM_JOB_NAME | $SLURM_JOB_NUM_NODES | $SLURM_JOB_QOS | $SLURM_JOB_CPUS_PER_NODE | $SLURM_TASKS_PER_NODE "
        traces2=" |  $MITGCM_FFLAGS $MITGCM_GENM_FLAGS | $elapsedtotal |"
tracesummary=${tracesummary1}${traces2}

echo $tracesummary 
echo $tracesummary > traceSummary.txt

../scripts/ecse_ecco_check.sh > eec.txt

