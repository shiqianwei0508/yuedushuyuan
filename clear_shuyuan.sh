if [ -z "$1" ]; then
  echo "Error: No json file, Please add a json file as the option!"
  exit 1
fi
cp $1 data.json

cat data.json | jq '.[].bookSourceUrl' |grep "https://" > https_website.txt
cat data.json | jq '.[].bookSourceUrl' |grep "http://" > http_website.txt

# 去掉双引号
#sed 's/"//g' http_website.txt > http_domains.txt
#sed 's/"//g' https_website.txt > https_domains.txt
# 继续清理
# 定义正则表达式
txtregex="((http|https|ftp)://)?(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])(\.[A-Za-z]{2,})+(:[0-9]+)?(/[A-Za-z0-9\-\._\?\,\'/\\\+&amp;%$#=~]*)*"

# 从文本中提取每一行的域名
while read line; do
  if [[ $line =~ $txtregex ]]; then
    echo "${BASH_REMATCH[0]}" >> http_domains.txt
  fi
done < http_website.txt
while read line; do
  if [[ $line =~ $txtregex ]]; then
    echo "${BASH_REMATCH[0]}" >> https_domains.txt
  fi
done < https_website.txt


# 结尾没有/的加上/
sed -i 's/\([^/]\)$/\1\//g' http_domains.txt
sed -i 's/\([^/]\)$/\1\//g' https_domains.txt

# 去掉 http:// 与 https://
#sed -i 's/http:\/\///g' http_website.txt
#sed -i 's/https:\/\///g' https_website.txt

# 提取域名
sed -i 's+.*\/\/\([^\/]*\)\/.*+\1+' http_domains.txt
sed -i 's+.*\/\/\([^\/]*\)\/.*+\1+' https_domains.txt


# 整合
paste -d " " http_website.txt http_domains.txt > http_work.txt
paste -d " " https_website.txt https_domains.txt > https_work.txt


# 检测http域名
while read line; do
  read -r thisUrl thisDomain <<< "$line"
  thisUrl=$(echo "$thisUrl" | sed 's/^"//;s/"$//')
  nc -zv -w 5 $thisDomain 80 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "-------------------$thisDomain 站点80端口正常，可继续使用-------------------------"
    else
        echo "------------$thisUrl || $thisDomain 站点80端口不通，删除不再使用-------------"
        jq --arg thewrongdomain "$thisUrl" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' data.json > tmp.json && mv tmp.json data.json
    fi
done < http_work.txt

# 检测https域名
while read line; do
  read -r thisUrl thisDomain <<< "$line"
  thisUrl=$(echo "$thisUrl" | sed 's/^"//;s/"$//')
  nc -zv -w 5 $thisDomain 443 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "-------------------$thisDomain 站点443端口正常，可继续使用-------------------------"
    else
        echo "------------$thisUrl || $thisDomain 站点443端口不通，删除不再使用-------------"
        jq --arg thewrongdomain "$thisUrl" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' data.json > tmp.json && mv tmp.json data.json
    fi
done < https_work.txt

# 输出剩余对象数量
count=$(jq length data.json)
echo "There are $count objects in data.json"
