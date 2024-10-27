#!/usr/bin/bash
gcc auth-overflow.c -fno-stack-protector -o mystery-bin-1
gcc auth-overflow-size-constraint.c -fno-stack-protector -o mystery-bin-2
