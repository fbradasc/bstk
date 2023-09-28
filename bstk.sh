#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PWD}/install/lib:${PWD}/install/lib64

export PATH=${PWD}/install/bin:${PATH}

baresip ${*}
