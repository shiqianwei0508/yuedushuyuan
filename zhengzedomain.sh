#!/bin/bash

# 定义正则表达式
regex="((http|https|ftp)://)?(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])(\.[A-Za-z]{2,})+(:[0-9]+)?(/[A-Za-z0-9\-\._\?\,\'/\\\+&amp;%$#=~]*)*"

# 从文本中提取每一行的域名
while read line; do
  if [[ $line =~ $regex ]]; then
    echo "${BASH_REMATCH[0]}" >> http_domains_1.txt
  fi
done < http_website.txt
