#  Flickr Browser

The app should be made of a single screen to list a set of images fetched from a JSON API, where the images should be shown in a grid layout (2 per row).

## API

The API to be used is from Flickr. You may need to use 2 endpoints to get to the images’ URLs:
flickr.photos.search
flickr.photos.getSizes

API Key: f9cc014fa76b098f9e82f1c288379ea1

**NOTES**
On this version, you should allow searching for images using the parameter tags.
The image tiles should use the images with label “Large Square”
You can paginate the results using the page parameter.

**EXAMPLES**

Get the first page of kitten images
https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=f9cc014fa76b098f9e82f1c288379ea1&tags=kitten&page=1&format=json&nojsoncallback=1

Get Sizes/URLs for a single image
https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=f9cc014fa76b098f9e82f1c288379ea1&photo_id=31456463045&format=json&nojsoncallback=1

Get the image data with the label “Large Square”
https://farm6.staticflickr.com/5800/31456463045_5a0af4ddc8_q.jpg

## REQUIREMENTS

### Must have

**UI**

- Must be implemented in UIKit (no SwiftUI for now)
- Grid layout (2 images per row)
- Should be memory efficient
- Network Layer
- Implement the necessary logic to perform the API requests for fetching the image list and image data

**Parsing**

- Implement the necessary logic to perform the API response parsing
- Unit Tests
- Your code should ideally have unit tests or at least be easily testable

**Language**

- Main target must be written in Swift, but you can still use Objective-C dependencies
- Version Control
- The app should be under a git repository.
- You can host the repo online, but please mark it as private.

### Nice to have (Extras)

_Note: This is not required, you can do it if you have time._
- Infinite scrolling
- Offline mode (use any existent images from a previous run, if no network available)
- Caching (cache response data to avoid hitting the network every time)  
- Tap an image and open it in full screen (use the image with “Large” label).
- Certificate pinning

## DELIVERY
To deliver the exercise, you should send an email to scout@mindera.com with the subject [iOS Practical Interview] - <your name>, containing:
Link to private repo on GitHub, BitBucket or GitLab, to which you should give access to the user mindera-ios-interview (or ios+interview@mindera.com)
Xcode and Swift versions
Any other relevant information or instructions
