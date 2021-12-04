#!/usr/bin/env bash

json=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/ryo-takaya/events | jq)
len=$(echo $json | jq length)

for i in $( seq 0 $(($len - 1)) ); do
  row=`echo ${json} | jq .[${i}]`
  eventType=`echo ${row} | jq -r .type`
  if [ "$eventType" = "PushEvent" ]; then
        createdAt=`echo ${row} | jq -r .created_at`
        format=${createdAt:0:10}
        today=$(date  +"%Y-%m-%d")
        if [ "$format" = "$today" ]; then
          echo ${format} ${today}
        fi
  fi

done