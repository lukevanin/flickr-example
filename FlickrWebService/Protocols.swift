//
//  Protocols.swift
//  FlickrWebService
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine


///
///
///
public struct FlickrError: Error {
    public let code: Int
    public let message: String
}


///
/// Criteria used for retrieving photos from the Flickr photos search API.
///
/// See: https://www.flickr.com/services/api/flickr.photos.search.html
///
public struct FlickrPhotosRequest {
    
    ///
    /// A comma-delimited list of tags. Photos with one or more of the tags listed will be returned. You can
    /// exclude results that match a term by prepending it with a - character.
    ///
    public var tags: [String] = []
}


///
/// A subset of the photos returned from by the Flickr photos search API.
///
/// See: https://www.flickr.com/services/api/flickr.photos.search.html
///
public struct FlickrPhotosResponse: Decodable {
    public struct Photos: Decodable {
        public struct Photo: Decodable {
            public let id: String
        }
        public let page: Int
        public let pages: Int
        public let perpage: Int
        public let photo: [Photo]
    }
    public let photos: Photos
}


///
/// Criteria for retreiving the size information for a specific photo.
///
/// See: https://www.flickr.com/services/api/flickr.photos.getSizes.html
///
public struct FlickrPhotoSizesRequest {
    
    ///
    /// Identifier of the photo which you want sizes for.
    ///
    public var id: String
}


///
/// Aavailable sizes for a Flickr photo
///
/// See: https://www.flickr.com/services/api/flickr.photos.getSizes.html
///
public struct FlickrPhotoSizesResponse: Decodable {
    public struct Sizes: Decodable {
        public struct Size: Decodable {
            public enum Label: String, Decodable {
                case largeSquare = "Large Square"
                case large = "Large"
            }
            public let label: Label?
            public let width: Int
            public let height: Int
            public let source: URL
            public let url: URL
        }
        public let size: Size
    }
    public let sizes: Sizes
}


///
/// API for interacting with the Flickr web service.
///
public protocol FlickrWebService {
    
    ///
    /// Returns a list of photos matching some criteria. Only photos visible to the calling user will be
    /// returned. To return private or semi-private photos, the caller must be authenticated with 'read'
    /// permissions, and have permission to view the photos. Unauthenticated calls will only return public
    /// photos.
    ///
    /// Flickr will return at most the first 4,000 results for any given search query.
    ///
    /// See: https://www.flickr.com/services/api/flickr.photos.search.html
    ///
    func getPhotos(request: FlickrPhotosRequest) -> AnyPublisher<FlickrPhotosResponse, FlickrError>
    
    ///
    /// Returns the available sizes for a photo. The calling user must have permission to view the photo.
    ///
    /// See: https://www.flickr.com/services/api/flickr.photos.getSizes.html
    ///
    func getPhotoSizes(request: FlickrPhotoSizesRequest) -> AnyPublisher<FlickrPhotoSizesResponse, FlickrError>
}
