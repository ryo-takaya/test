#!/usr/bin/env bash

set -e

function push_commit (){
  for i in `seq $1`;do
    echo 'hoge' >> ./hoge.txt
    git add ./hoge.txt
    git commit -m "$(gdate +"%Y-%m-%d"):$i 回目の自動プッシュ"
    git push
  done
}

function eval_push_date (){
  local commit_datetime=$1; local result
  commit_datetime=`echo ${commit_datetime%Z}`
  commit_datetime=`echo ${commit_datetime//T/ }`
  result=$(gdate -d "9 hours $commit_datetime" +"%Y-%m-%d")
  echo $result
}

declare -i today_push_count=0
readonly PUSH_QUOTA_COUNT=5

json=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/ryo-takaya/events | jq)
len=$(echo $json | jq length)

for i in $( seq 0 $(($len - 1)) ); do
  row=`echo ${json} | jq .[${i}]`
  event_type=`echo ${row} | jq -r .type`

  if [ ${event_type} = "PushEvent" ]; then
    created_datetime=`echo ${row} | jq -r .created_at`
    push_date=`eval_push_date $created_datetime`
    today=$(gdate +"%Y-%m-%d")
    if [ "$push_date" = "$today" ]; then
      today_push_count=$((today_push_count+1))
    fi
  fi
done

additional_push_count=$((PUSH_QUOTA_COUNT-today_push_count))
if [ $additional_push_count -gt 0 ]; then
  push_commit $additional_push_count
else
  echo "今日は既に$PUSH_QUOTA_COUNT 回のプッシュをしています"
fi