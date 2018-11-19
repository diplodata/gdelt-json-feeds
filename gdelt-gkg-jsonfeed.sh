
# cd /path/to

GDELTCALL='https://api.gdeltproject.org/api/v1/gkg_geojson?QUERY=BORDER,EPU_ECONOMY,geoname:Ireland,lang:eng&TIMESPAN=1000&MAXROWS=500&OUTPUTFIELDS=name,url,domain,sharingimage,geores,themes'

query=$(echo $GDELTCALL | grep -Poi '(?<=query=)[^&]+' | 
  sed -e 's:query=:query\: :Ig' | 
  sed -e 's:%20:, :g' | 
  sed -e 's:%22:":g' | 
  sed -e 's:,:, :g')

j=$(curl $GDELTCALL)

echo $j | jq -r --arg time "$(date)" --arg desc "$query" --arg home "$GDELTCALL" '
.["version"] = "https://jsonfeed.org/version/1" |
.["title"] = "GDELT - " + $desc |
.["home_page_url"] = $home |
.["feed_url"] = $home |
.["description"] = $time |
.["items"] = (.features | [ .[] | .properties |
{
  "id": .url,
  "title": ((.name | match(["^[^,]+" , "is"])["string"]) + ": " + (.url | match(["[^/]+/?$" , "is"])["string"] | gsub("-";" ") | sub("/$";"") | sub(".html?$";""))),
  "content_text": ("[" + .domain + "] " + "GDELT Themes: " + (.mentionedthemes | sub("^;"; "") | sub(";$"; "") | gsub(";"; ", "))),
  "date_published": .urlpubtimedate,
  "url": .url,
  "author": {
    "name": .domain,
    "url": .url | match(["https?://[^/]+" , "is"])["string"],
  },
  "image": .urlsocialimage
}
] | unique_by(.id) | unique_by(.title) | map(select(.geores != 1)) ) |
del(.features, .type)' > gkg.json
