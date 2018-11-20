#!/bin/bash

gdelt_geo()
{
  query=$(echo $1 | grep -Poi '(?<=query=)[^&]+' |
  sed -e 's:query=:query\: :Ig' |
  sed -e 's:%20:, :g' |
  sed -e 's:%22:":g');
  # get data
  j="$(curl $1)";
  # # parse to JSONFeed
  echo "$j" | jq -r --arg time "$(date)" --arg desc "$query" --arg home "$1" '
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
    del(.features, .type)';
}

gdelt_gkg()
{
  query=$(echo $1 | grep -Poi '(?<=query=)[^&]+' |
    sed -e 's:query=:query\: :Ig' |
    sed -e 's:%20:, :g' |
    sed -e 's:%22:":g' |
    sed -e 's:,:, :g')
  # get data
  j=$(curl $1)
  # parse to JSONFeed
  echo "$j" | jq -r --arg time "$(date)" --arg desc "$query" --arg home "$1" '
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
    del(.features, .type)'
}

if [[ "$1" == *"api/v2/geo"* ]]; then
    gdelt_geo $1;
else
    gdelt_gkg $1;
fi
