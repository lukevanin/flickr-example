//
//  FlickrRESTServiceIntegrationTests.swift
//  FlickrWebServiceTests
//
//  Created by Luke Van In on 2021/06/16.
//

import XCTest
import Combine

import Transport

@testable import FlickrWebService

final class FlickrRESTServiceIntegrationTests: XCTestCase {

    private let service: FlickrRESTService = {
        return FlickrRESTService(
            configuration: FlickrRESTService.Configuration(
                key: ProcessInfo.processInfo.environment["FLICKR_API_KEY"]!
            )
        )
    }()
    
    func testGetPhotosShouldReturnPhotos() throws {
        let operation = service.getPhotos(
            request: FlickrPhotosRequest(
                page: 1,
                tags: ["kittens"]
            )
        )
        let _ = try wait(for: operation, timeout: 10)
    }
    
    func testGetPhotoSizeShouldReturnPhotoSize() throws {
        let operation = service.getPhotoSizes(
            request: FlickrPhotoSizesRequest(
                id: "51250541752"
            )
        )
        let = _ try wait(for: operation, timeout: 10)
    }

}
