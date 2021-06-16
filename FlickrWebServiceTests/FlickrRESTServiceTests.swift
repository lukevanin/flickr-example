//
//  FlickrWebServiceTests.swift
//  FlickrWebServiceTests
//
//  Created by Luke Van In on 2021/06/16.
//

import XCTest
import Combine

import Transport

@testable import FlickrWebService

var cancellables = Set<AnyCancellable>()

extension XCTestCase {
    
    ///
    /// Waits for a combine publisher to emit a value or error.
    ///
    func wait<P>(
        for publisher: P,
        description: String = "publisher",
        timeout: TimeInterval = 1,
        file: StaticString = #file,
        line: Int = #line
    ) throws -> P.Output? where P: Publisher {
        var result: Result<P.Output, P.Failure>!
        let expectation = expectation(description: description)
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        result = .failure(error)
                        expectation.fulfill()
                    case .finished:
                        break
                    }
                },
                receiveValue: { value in
                    result = .success(value)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: timeout)
        // This will crash if the published stream closes before without
        // emitting a value or error.
        return try result?.get()
    }
}


final class FlickrRESTServiceTests: XCTestCase {

    func testGetPhotosShouldReturnPhotos() throws {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            XCTAssertEqual(path, "/")
            XCTAssert(parameters.contains(URLQueryItem(name: "method", value: "flickr.photos.search")))
            XCTAssert(parameters.contains(URLQueryItem(name: "api_key", value: "**********")))
            XCTAssert(parameters.contains(URLQueryItem(name: "page", value: "2")))
            XCTAssert(parameters.contains(URLQueryItem(name: "format", value: "json")))
            return """
                {
                    "photos": {
                        "page": 2,
                        "pages": 10,
                        "perpage": 1,
                        "photo":[
                            {
                                "id": "1",
                            },
                        ]
                    }
                }
            """
        }
        let subject = FlickrRESTService(
            configuration: FlickrRESTService.Configuration(
                key: "**********"
            ),
            transport: transport
        )
        let expected = FlickrPhotosResponse(
            photos: FlickrPhotosResponse.Photos(
                page: 2,
                pages: 10,
                perpage: 1,
                photo: [
                    FlickrPhotosResponse.Photos.Photo(
                        id: "1"
                    )
                ]
            )
        )
        let operation = subject.getPhotos(
            request: FlickrPhotosRequest(
                page: 2
            )
        )
        let response = try wait(for: operation)
        XCTAssertEqual(response, expected)
    }
    
    func testGetPhotosWithSingleTagsShouldNotDelimitTags() throws {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            XCTAssert(parameters.contains(URLQueryItem(name: "tags", value: "kittens")))
            return """
                {
                    "photos": {
                        "page":1,
                        "pages": 10,
                        "perpage": 1,
                        "photo":[]
                    }
                }
            """
        }
        let subject = FlickrRESTService(
            configuration: FlickrRESTService.Configuration(
                key: "**********"
            ),
            transport: transport
        )
        let expected = FlickrPhotosResponse(
            photos: FlickrPhotosResponse.Photos(
                page: 1,
                pages: 10,
                perpage: 1,
                photo: []
            )
        )
        let operation = subject.getPhotos(
            request: FlickrPhotosRequest(
                tags: ["kittens"]
            )
        )
        let response = try wait(for: operation)
        XCTAssertEqual(response, expected)
    }

    func testGetPhotosWithMultipleTagsShouldDelimitTags() throws {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            XCTAssert(parameters.contains(URLQueryItem(name: "tags", value: "kittens,puppies")))
            return """
                {
                    "photos": {
                        "page":1,
                        "pages": 10,
                        "perpage": 1,
                        "photo":[]
                    }
                }
            """
        }
        let subject = FlickrRESTService(
            configuration: FlickrRESTService.Configuration(
                key: "**********"
            ),
            transport: transport
        )
        let expected = FlickrPhotosResponse(
            photos: FlickrPhotosResponse.Photos(
                page: 1,
                pages: 10,
                perpage: 1,
                photo: []
            )
        )
        let operation = subject.getPhotos(
            request: FlickrPhotosRequest(
                tags: ["kittens", "puppies"]
            )
        )
        let response = try wait(for: operation)
        XCTAssertEqual(response, expected)
    }
    
    func testGetPhotosShouldFailWhenTransportFails() {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            throw URLError(.cancelled)
        }
        let subject = FlickrRESTService(
            configuration: FlickrRESTService.Configuration(key: ""),
            transport: transport
        )
        let operation = subject.getPhotos(request: FlickrPhotosRequest())
        XCTAssertThrowsError(try wait(for: operation))
    }
    
    func testGetPhotoSizesShouldReturnPhotoSizes() {
        
    }
 
    func testGetPhotoSizesShouldFailWhenTransportFails() {
        
    }
}
