if [ -z "$1" ]; then
  echo "Error: No website specific"
  exit 1
fi

line=$1

jq --arg thewrongdomain "$line" 'del( .[] | select(.bookSourceUrl == $thewrongdomain) )' my2.0shuyuan.json > tmp.json && mv tmp.json my2.0shuyuan.json
