#!/bin/bash

for i in {0..1410}
do 
  bsub -q all_unlimited -N -oo ./logfile time /opt/RepeatMasker/RepeatMasker -gccalc -noisy -dir ../RepeatMasker/ -a -small -source -small -xsmall -gff -engine abblast -species vertebrata  ./Apalone_qf_$i
done

