export ECCO_SRUND="block:block"
export MITGCM_NPES=360

export ECCO_QOS="standard"
export ECCO_NODES=3
export ECCO_TASKS_PER_NODE=$((${MITGCM_NPES}/$ECCO_NODES))
export ECCO_EXE="mitgcmuv"

export ECCO_TIME="02:30:00"


