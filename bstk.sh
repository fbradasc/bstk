#!/bin/bash

export LD_LIBRARY_PATH=${PWD}/install/lib:${PWD}/install/lib64

export PATH=${PWD}/install/bin:${PATH}

export LD_PRELOAD=${PWD}/install/lib64/libssl.so.3

baresip ${*}
