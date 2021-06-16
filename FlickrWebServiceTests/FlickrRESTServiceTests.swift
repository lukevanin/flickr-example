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
    
    // MARK: Get Photos

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
    
    // MARK: Get Photo Sizes
    
    func testGetPhotoSizesShouldReturnPhotoSizes() throws {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            XCTAssertEqual(path, "/")
            XCTAssert(parameters.contains(URLQueryItem(name: "method", value: "flickr.photos.getSizes")))
            XCTAssert(parameters.contains(URLQueryItem(name: "api_key", value: "**********")))
            XCTAssert(parameters.contains(URLQueryItem(name: "format", value: "json")))
            XCTAssert(parameters.contains(URLQueryItem(name: "photo_id", value: "3")))
            return """
                {
                    "sizes": {
                        "size": [
                            {
                                "label": "Large",
                                "width": 27,
                                "height": 72,
                                "source": "https://live.staticflickr.com/l",
                                "url": "https://www.flickr.com/l",
                            },
                            {
                                "label": "Large Square",
                                "width": 95,
                                "height": 59,
                                "source": "https://live.staticflickr.com/q",
                                "url": "https://www.flickr.com/q",
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
        let expected = FlickrPhotoSizesResponse(
            sizes: FlickrPhotoSizesResponse.Sizes(
                size: [
                    FlickrPhotoSizesResponse.Sizes.Size(
                        label: .large,
                        width: 27,
                        height: 72,
                        source: URL(string: "https://live.staticflickr.com/l")!,
                        url: URL(string: "https://www.flickr.com/l")!
                    ),
                    FlickrPhotoSizesResponse.Sizes.Size(
                        label: .largeSquare,
                        width: 95,
                        height: 59,
                        source: URL(string: "https://live.staticflickr.com/q")!,
                        url: URL(string: "https://www.flickr.com/q")!
                    ),
                ]
            )
        )
        let operation = subject.getPhotoSizes(
            request: FlickrPhotoSizesRequest(id: "3")
        )
        let response = try wait(for: operation)
        XCTAssertEqual(response, expected)
    }
    
    func testGetPhotoSizesShouldReturnEmptyLabelWhenNameIsNotSupported() throws {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            XCTAssertEqual(path, "/")
            XCTAssert(parameters.contains(URLQueryItem(name: "method", value: "flickr.photos.getSizes")))
            XCTAssert(parameters.contains(URLQueryItem(name: "api_key", value: "**********")))
            XCTAssert(parameters.contains(URLQueryItem(name: "format", value: "json")))
            XCTAssert(parameters.contains(URLQueryItem(name: "photo_id", value: "3")))
            return """
                {
                    "sizes": {
                        "size": [
                            {
                                "label": "Goober",
                                "width": 27,
                                "height": 72,
                                "source": "https://live.staticflickr.com/l",
                                "url": "https://www.flickr.com/l",
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
        let expected = FlickrPhotoSizesResponse(
            sizes: FlickrPhotoSizesResponse.Sizes(
                size: [
                    FlickrPhotoSizesResponse.Sizes.Size(
                        label: nil,
                        width: 27,
                        height: 72,
                        source: URL(string: "https://live.staticflickr.com/l")!,
                        url: URL(string: "https://www.flickr.com/l")!
                    ),
                ]
            )
        )
        let operation = subject.getPhotoSizes(
            request: FlickrPhotoSizesRequest(id: "3")
        )
        let response = try wait(for: operation)
        XCTAssertEqual(response, expected)
    }

    func testGetPhotoSizesShouldFailWhenTransportFails() {
        let transport = MockTransport()
        transport.mockGet = { path, parameters in
            throw URLError(.cancelled)
        }
        let subject = FlickrRESTService(
            configuration: FlickrRESTService.Configuration(key: ""),
            transport: transport
        )
        let operation = subject.getPhotoSizes(
            request: FlickrPhotoSizesRequest(id: "3")
        )
        XCTAssertThrowsError(try wait(for: operation))

    }
}
