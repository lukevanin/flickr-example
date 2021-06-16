//
//  JSONTransportTests.swift
//  TransportTests
//
//  Created by Luke Van In on 2021/06/16.
//

import XCTest
import Combine

@testable import Transport


private var cancellables = Set<AnyCancellable>()


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
    

final class JSONTransportTests: XCTestCase {
    
    private struct SamplePost: Codable, Equatable {
        let id: Int
    }
    
    private struct SampleComment: Codable, Equatable {
        let id: Int
        let postId: Int
    }
    
    private struct NonConformingType: Codable, Equatable {
        struct InternalType: Codable, Equatable {
        }
        let internalType: InternalType
    }
    
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
    
    ///
    /// Calling the GET method on a URL should return the deserialized contents of the response when the
    /// data matches the expected format.
    ///
    func testGetShouldReturnContentWhenRequestReturnsConformingData() throws {
        let subject = JSONTransport(url: baseURL)
        let expected = SamplePost(id: 1)
        let operation = subject.get(SamplePost.self, path: "/todos/1")
        let result = try wait(for: operation)
        XCTAssertEqual(expected, result)
    }
    
    ///
    /// Calling the GET method on a URL with a query parameter should return the deserialized contents of
    /// the response when the response conforms to the expected type.
    ///
    func testGetShouldReturnContentWhenRequestWithQueryParameterReturnsConformingData() throws {
        let subject = JSONTransport(url: baseURL)
        let expected = [
            SampleComment(id: 1, postId: 1),
            SampleComment(id: 2, postId: 1),
            SampleComment(id: 3, postId: 1),
            SampleComment(id: 4, postId: 1),
            SampleComment(id: 5, postId: 1),
        ]
        let operation = subject.get([SampleComment].self, path: "/comments", parameters: [URLQueryItem(name: "postId", value: "1")])
        let result = try wait(for: operation)
        XCTAssertEqual(expected, result)
    }
    
    ///
    /// Calling the GET method on a URL with a query parameter should fail when the response does not
    /// conforms to the expected type
    ///
    func testGetShouldFailWhenRequestWithQueryParameterReturnsNonconformingData() throws {
        let subject = JSONTransport(url: baseURL)
        let request = subject.get([NonConformingType].self, path: "/comments", parameters: [URLQueryItem(name: "postId", value: "1")])
        XCTAssertThrowsError(try wait(for: request))
    }

    ///
    /// Calling the GET method on a URL should return an error when the data returned by the URL does
    /// not match the expected format.
    ///
    func testGetShouldFailWhenRequestReturnsNonConformingData() throws {
        let subject = JSONTransport(
            url: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        XCTAssertThrowsError(try wait(for: subject.get(NonConformingType.self, path: "/todos/1")))
    }
    
    ///
    /// Calling the GET method on a URL should fail if the URL resource does not exist.
    ///
    func testGetShouldFailWhenRequestCallsNonexistingURL() {
        let subject = JSONTransport(
            url: URL(string: "https://nowhere.example.org")!
        )
        XCTAssertThrowsError(try wait(for: subject.get(SamplePost.self, path: "/todos/1")))
    }
}
