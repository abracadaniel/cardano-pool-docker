#!/bin/bash

docker build -t droe/cardano-node:pioneer --build-arg cardano_branch=tags/pioneer .
