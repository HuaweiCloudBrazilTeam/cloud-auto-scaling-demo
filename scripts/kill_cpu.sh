#!/bin/bash

stress -c $[$(grep "processor" /proc/cpuinfo | wc -l) * 8] -i 4 --verbose --timeout 15m
