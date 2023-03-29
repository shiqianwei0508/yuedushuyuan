cat data.json |grep "By Dark" | awk -F'"' '{print $4}' > byDark.txt

while read -r line; do
  # 处理每一行数据，$line 变量包含整个行的内容
  jq --arg thewrongdomain "$line" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' data.json > tmp.json && mv tmp.json data.json
done < byDark.txt
