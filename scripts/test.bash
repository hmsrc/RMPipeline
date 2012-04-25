#!/bin/bash

bsub -q all_12h  -N -oo ../Chelonia_mydas/GC_cli2.log perl ./GC_cli.pl -M ../Chelonia_mydas/RepeatMasker/MasterFile.out -O ../Chelonia_mydas/Chelonia_GC2 -F ../Chelonia_mydas/GRE.gapCloser.fa.fill.fill.fa
