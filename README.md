# eCSE-archer2-eccov4r4

Specific options for ECCOv4-r4 for ARCHER2 for eCSE optimisation project. This repository contains:
 - files used and produced on Archer, taken as a basis for the port to Archer2
 - corresponding files on arcehr2 after the porting.

## Description of contents of repository

### code
 contains the SIZE.h files, the appropriate on eof which was used at compile time to create the 96, 192 and 360 core executables

### inpit_init
 - input_init/NAMELIST : contains the data file used at runtime (model runtime changed to 18 months)
 - data.exch2 files, for each case of 096, 192,360 MPI processes.

### Archer
This repository contains data for ECCOv4 (release 4) benchmark runs carried out on ARCHER. It includes code required to reproduce the benchmark runs, output from those runs, and some processing scripts.

Directories and files:
 - build_096 : contains a genmake.log file from the build on ARCHER
 - build_360 : contains a genamke.log file from the build on ARCHER
 - results : contains standard output, including profiling information, from 96 and 360 core runs
 - run_096-01 : contains job submission script
 - run_360-01 : contains job submission script
 - scripts: contains an initial run setup script and a script to process the standard output
 
The idea is to compare the standard output (e.g. ``STDOUT.0000`` from a given run) with the standard output saved in the ``results`` directory. These output files can be processed with the ``ecse_ecco_check.sh`` script in the ``scripts`` directory.

### Archer2
Build, run and results files for each of the cases of 96,192,360 processes.
The rundef and slurm scripts take the form they have as this was used in running many tests.

## How to reproduce the benchmarking run

First, obtain the MITgcm source code and ECCOv4-r4 setup, e.g. as detailed in the ARCHER2 documentation:

https://docs.archer2.ac.uk/research-software/mitgcm/mitgcm/

### Changing the number of processes/cores
The default number of processes is 96. To change this, you must change some variables in the file ``code/SIZE.h``. Specifically, for 360 cores, use the following values in ``SIZE.h``:

    sNx = 15,
    sNy = 15,
    nPx = 360,
    
This decreases the size of the tiles and increases the total number of tiles. 

### Setting up the model run
To run the model, create a run directory and use the setup script from the arcehr directory:

    mkdir my_run_directory
    cd my_run_directory
    ../scripts/prepare_eccov4r4.sh
    cp ../build/mitgcmuv .
    
### Changing the length of the run
The full model run is longer than needed for testing purposes. This benchmark case was run for 18 months. To replicate this, change the parameter ``nTimeSteps`` in the file ``data``:

    nTimeSteps=13110,
    
### Changing the tiling
In the file ``data.exch2``, there are different options for different tile arrangements. You have to manually comment out and uncomment the appropriate lines for the selected number of cores. If these options are set incorrectly, the job will fail to pass its startup checks and will fail. 
    
### check debug (trace output) is turned off
In eedata, debugMode=FALSE

### Submitting the job    
Finally, use a job submission script to get the job onto the local scheduler, if relevant. If successful, the run will produce a set of ``STDOUT`` files that can be analysed. To get some summary statistics, use the script ``scripts/ecse_ecco_check.sh``. You can run this script on the sample output for comparison. 

### Validating a run
We can validate a run using two criteria:

  1. The job should complete normally (standard output ends with ``STOP NORMAL END``)
  2. The temperature and salinity statistics match those produced by those produced using the ``scripts/ecse_ecco_check.sh`` script, at least up to a reasonable number of decimal places. 
    On Archer2 the file ee.ctxt was produced in the slurm job, to facilitate this check.

## Comparing with wall clock time
The simplest performance metric is total wall clock time. Here are the total wall clock times for the benchmarking runs carried out on ARCHER:

    96 cores : 2.94 hours
    360 cores : 2.25 hours
  
And on Archer2 (secs) using the STDOUT.0000 file with ecse_ecco_check.sh:
    96 cores : (1 node) : 3307
    192 cores (2 nodes) : 2239
    360 cores (3 nodes) : 1970 (We noted a wide scatter of results with 360 cores, which was not understood. This was the best of three runs)
  
Based on the processor count alone, there is low parallel efficiency (i.e. the ratio of actual speedup to the linear speedup) of 35%. This drop may represent a bottleneck in node-to-node communication.  

The project report discusses the need to identify the cheapest (in terms of node hours), not just the fastest, configurations. This is with 96 cores. 
