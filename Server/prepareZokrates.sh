#!/bin/bash

curl -LSfs get.zokrat.es | sh
export PATH=$PATH:$HOME/.zokrates/bin
export ZOKRATES_HOME=$HOME/.zokrates/stdlib
zokrates --version