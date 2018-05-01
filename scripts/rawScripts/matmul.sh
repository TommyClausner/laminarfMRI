#!/bin/bash
awk 'NR==FNR {
        for(i=1;i<=NF;i++)A[i,NR]=$i
        next
      }
      {
        for(i=1;i<=NF;i++){
          t=0
          for(j=1;j<=NF;j++)
            t+=A[i,j]*$j
          printf t FS
        }
        print ""
      }' $1 $2
