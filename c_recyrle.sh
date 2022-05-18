#!/bin/bash
find /zsysvol -maxdepth 2 -name ".recycle" -exec rm -rf {} \;
