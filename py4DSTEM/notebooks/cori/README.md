# Quickstart instructions

- Create the conda envirnoment

    module load python/3.6-anaconda-5.2
    conda create env > py4dstem_env.yml

- Create a kernel from this environment for running the notebooks

    source activate py4dstem
    python -m ipykernel install --user --name py4dstem --display_name py4dstem

- For running on the interactive queue, first request resources via salloc.

    salloc -A <account> -C haswell -t <h:mm:ss> -N <number of nodes> -q interactive -J <unique job id>

- In this salloc terminal session, start an ipyparallel or dask cluster.

-- IPyParallel

    ./startCluster -N <number of nodes> -n <number of engines per node>

-- Dask

    ./startCluster -d -N <number of nodes> -n <number of workers per node>