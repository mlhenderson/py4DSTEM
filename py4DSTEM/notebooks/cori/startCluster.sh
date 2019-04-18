#!/bin/bash

DASK=0
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -N|--nodes)
    NODES="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--num_procs)
    NUMPROCS="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--ipyparallel)
    DASK=0
    shift # past argument
    ;;
    -d|--dask)
    DASK=1
    shift # past argument
    ;;
  esac
done

num_nodes=$NODES

if [ "$num_nodes" = "" ]; then
  num_nodes=1
fi

num_procs=$NUMPROCS

if [ "$num_procs" = "" ]; then
  num_procs=32
fi

# Dask

start_dask_cluster()
{
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
  export OMP_NUM_THREADS=1
  export HDF5_USE_FILE_LOCKING=FALSE

  echo "Launching dask scheduler"
  dask-scheduler --host "$headIP" --local-directory $SCRATCH --scheduler-file dask_scheduler.json &

  sleep 20

  echo "Launching $num_procs dask workers for $num_nodes nodes"
  srun -N $num_nodes --ntasks-per-node=$num_procs dask-worker --local-directory $SCRATCH --scheduler-file dask_scheduler.json --nthreads 1 --memory-limit 0
}

# IPyParallel

start_ipp_cluster()
{
  export OMP_NUM_THREADS=1

  # Use a unique cluster ID for this job
  clusterID=cori_${SLURM_JOB_ID}

  echo "Launching controller"
  ipcontroller --ip="$headIP" --cluster-id="$clusterID" --nodb &

  sleep 20

  echo "Launching engines"
  srun -N $num_nodes --ntasks-per-node=$num_procs ipengine --cluster-id="$clusterID" --work-dir=$SCRATCH
}



### Main

# Get the IP address of our head node
headIP=$(ip addr show ipogif0 | grep '10\.' | awk '{print $2}' | awk -F'/' '{print $1}')

if [ "$DASK" = "1" ]; then
    start_dask_cluster
else
    start_ipp_cluster
fi
