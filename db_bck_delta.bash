#!/bin/bash

bck_time="$(sudo date --utc --reference=/backup/db/daily/${1} +%s)"
now_time="$(date --utc +%s)"
echo $((now_time-bck_time))
