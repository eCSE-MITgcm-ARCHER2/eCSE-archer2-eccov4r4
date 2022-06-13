export MYQUEUE="--partition standard --qos standard"
myrun=dAn1_5_bc
myargs="--time=2:0:0 --nodes=1 --tasks-per-node=96"
sbatch --job-name=$myrun ${myargs//\"} ${MYQUEUE//\"}  ../scripts/run_submit.slurm

