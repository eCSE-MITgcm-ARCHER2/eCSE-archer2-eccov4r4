export ECCO_SRUND="block:block"

# separate to ese extractin of suimmary from
#export ECCO_SBATCH=" --partition=standard --qos=short --time=0:20:0 --nodes=3 --tasks-per-node=120"

export ECCO_QOS="standard"
export ECCO_NODES=2
export ECCO_TASKS_PER_NODE=$((${MITGCM_NPES}/$ECCO_NODES))
export ECCO_EXE="mitgcmuv"

export ECCO_TIME="02:30:00"


