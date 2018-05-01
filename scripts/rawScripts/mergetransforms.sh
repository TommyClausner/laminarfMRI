#!/bin/bash
awk 'NR==FNR {
        for(i=1;i<=NF;i++)A[i,0]=$i
        next
      }
      {
        for(i=1;i<=NF;i++){
          t=A[i,0]+$i
          printf t FS FS
        }
        print ""
      }' $1 $2


