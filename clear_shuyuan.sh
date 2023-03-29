if [ -z "$1" ]; then
  echo "Error: No json file, Please add a json file as the option!"
  exit 1
fi
cp $1 data.json

cat data.json | jq '.[].bookSourceUrl' |grep "https://" > https_website.txt
cat data.json | jq '.[].bookSourceUrl' |grep "http://" > http_website.txt

# 去掉双引号
sed -i 's/"//g' http_website.txt
sed -i 's/"//g' https_website.txt

# 去掉 http:// 与 https://
sed -i 's/http:\/\///g' http_website.txt
sed -i 's/https:\/\///g' https_website.txt


# 检测http域名
for i in `cat http_website.txt`
do
    nc -zv -w 3 $i 80 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "-------------------$i站点80端口正常，可继续使用-------------------------"
    else
        echo "------------$i站点80端口不通，删除不再使用-------------"
        jq --arg thewrongdomain "http://$i" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' data.json > tmp.json && mv tmp.json data.json
    fi
done

# 检测https域名
for i in `cat https_website.txt`
do
    nc -zv -w 3 $i 443 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "-------------------$i站点443端口正常，可继续使用-------------------------"
    else
        echo "------------$i站点443端口不通，删除不再使用-------------"
        jq --arg thewrongdomain "https://$i" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' data.json > tmp.json && mv tmp.json data.json
    fi
done

# 输出剩余对象数量
count=$(jq length data.json)
echo "There are $count objects in data.json"
