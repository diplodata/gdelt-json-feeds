# GDELT Geo-JSONFeed

### Tools to reformat GDELT's geographical APIs GeoJSON outputs into  JSONFeed

[JSONFeed](https://jsonfeed.org/) is JSON's specification for RSS-like news/info feeds.  GDELT offers 2 main geographical APIs that enable you to identify breaking news content that references particular places of regions:

- [GEO API](https://blog.gdeltproject.org/gdelt-geo-2-0-api-debuts/)
- [Global Knowledge Graph GeoJSON API](https://blog.gdeltproject.org/announcing-our-first-api-gkg-geojson/)

Both APIs offer GeoJSON outputs.  The scripts in this repo will parse these outputs into JSONFeed - so you can set up very specific monitors and pipe the matching articules through to your RSS/news reader.

Note these APIs work in quite different ways and have different strengths and limitations.
