
# cd /path/to

GDELTCALL='https://api.gdeltproject.org/api/v2/geo/geo?query=brexit%20locationcc:EI&mode=PointData&format=GeoJSON&timespan=1d'

query=$(echo $GDELTCALL | grep -Poi '(?<=query=)[^&]+' | 
  sed -e 's:query=:query\: :Ig' | 
  sed -e 's:%20:, :g' | 
  sed -e 's:%22:":g')

j=$(curl $GDELTCALL)

echo $j | jq -r --arg time "$(date)" --arg desc "$query" --arg home "$GDELTCALL" '
.["version"] = "https://jsonfeed.org/version/1" |
.["title"] = "GDELT - " + $desc |
.["home_page_url"] = $home |
.["feed_url"] = $home |
.["description"] = $time |
.["items"] = (.features | [ .[] | .properties |
{
  "id": .html | match(["http[^\"]+", "is"])["string"],
  "title": .html | match(["(?<=>)[^<]+", "is"])["string"], 
  "content_html": ("<p>[" + (.html | match(["(?<=//)[^/]+" , "is"])["string"] | sub("^www[0-9]?."; "")) + "] </p>" + .html),
  "url": .html | match(["http[^\"]+", "is"])["string"],
  "author": { 
      "name": .html | match(["(?<=//)[^/]+" , "is"])["string"] | sub("^www[0-9]?."; ""),
      "url":  .html | match(["https?://[^/]+", "is"])["string"]
    },
  "image": .shareimage
}
] | unique_by(.id) | unique_by(.title)) |
del(.features, .type)' > geo.json
