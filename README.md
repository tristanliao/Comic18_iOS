# Comic18_iOS


## API Response

### Home

### Detail

```
{
  "id": string,
  "title": string,
  "cover_image": string,
  "preview_images": [string],
  "authors": [string],
  "tags": [string],
  "description": string,
  "pages": int,
  "release_date": string, // This is a string because we can't get a timestamp from the HTML.
  "update_date": string, // This is a string because we can't get a timestamp from the HTML.
  "watch_count": int,
  "like_count": string, // This is a string because the web shows 23.5k for example and there's no accurate number to get.
  "chapters": [
    {
      "id": string,
      "number": int,
      "title": string,
      "release_date": string
    }
  ]
}
```
