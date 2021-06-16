//
//  FlickrRESTService.swift
//  FlickrWebService
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine

import Transport


public final class FlickrRESTService<Transport>: FlickrService where Transport: RESTTransport {
    
    public struct Configuration {
        let key: String
    }
    
    private let configuration: Configuration
    private let transport: Transport
    
    public init(configuration: Configuration, transport: Transport) {
        self.configuration = configuration
        self.transport = transport
    }
    
    public func getPhotos(request: FlickrPhotosRequest) -> AnyPublisher<FlickrPhotosResponse, Error> {
        transport.get(
            path: "/",
            parameters: [
                URLQueryItem(
                    name: "format",
                    value: "json"
                ),
                URLQueryItem(
                    name: "method",
                    value: "flickr.photos.search"
                ),
                URLQueryItem(
                    name: "api_key",
                    value: configuration.key
                ),
                URLQueryItem(
                    name: "tags",
                    value: request.tags.joined(separator: ",")
                ),
                URLQueryItem(
                    name: "page",
                    value: String(request.page)
                ),
            ]
        )
    }
    
    public func getPhotoSizes(request: FlickrPhotoSizesRequest) -> AnyPublisher<FlickrPhotoSizesResponse, Error> {
        transport.get(
            path: "/",
            parameters: [
                URLQueryItem(
                    name: "format",
                    value: "json"
                ),
                URLQueryItem(
                    name: "method",
                    value: "flickr.photos.getSizes"
                ),
                URLQueryItem(
                    name: "api_key",
                    value: configuration.key
                ),
                URLQueryItem(
                    name: "photo_id",
                    value: request.id
                ),
            ]
        )
    }
}
