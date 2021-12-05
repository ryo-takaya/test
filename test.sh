#!/usr/bin/env bash

set -e

function pushCommit (){
  for i in `seq $1`;do
    echo 'hoge' >> ./hoge.txt
    git add ./hoge.txt
    git commit -m "$(gdate +"%Y-%m-%d"):$i 回目の自動コミット"
  done
  git push
}

function evalCommitDate (){
  commitDatetime=$1
  commitDatetime=`echo ${commitDatetime%Z}`
  commitDatetime=`echo ${commitDatetime//T/ }`
  result=$(gdate -d "9 hours $commitDatetime" +"%Y-%m-%d")
  echo $result
}

declare -i todayCommitCount=0

json=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/ryo-takaya/events | jq)
len=$(echo $json | jq length)

for i in $( seq 0 $(($len - 1)) ); do
  row=`echo ${json} | jq .[${i}]`
  eventType=`echo ${row} | jq -r .type`

  if [ ${eventType} = "PushEvent" ]; then
    createdAt=`echo ${row} | jq -r .created_at`
    evalCommitDate $createdAt
    commitTime=`evalCommitDate $createdAt`
    today=$(gdate +"%Y-%m-%d")
    if [ "$commitTime" = "$today" ]; then
      todayCommitCount=$((todayCommitCount+1))
    fi
  fi
done

additionCommitCount=$((6-todayCommitCount))
if [ $additionCommitCount -gt 0 ]; then
  pushCommit $additionCommitCount
fi