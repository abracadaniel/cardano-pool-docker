#!/bin/bash

docker build -t droe/cardano-node:latest --build-arg cardano_branch=master .
