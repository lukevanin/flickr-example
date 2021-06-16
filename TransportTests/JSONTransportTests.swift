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
    
    private struct Sample: Codable, Equatable {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
    }
    
    private struct NonConformingType: Codable, Equatable {
        struct InternalType: Codable, Equatable {
        }
        let internalType: InternalType
    }

    
    #warning("TODO: Test parameter encoding")


    ///
    /// Calling the GET method on a URL should return the deserialized contents of the response when the
    /// data matches the expected format.
    ///
    func testGetShouldReturnContentWebRequestReturnsConformingData() throws {
        let subject = JSONTransport(
            url: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        let expected = Sample(
            userId: 1,
            id: 1,
            title: "delectus aut autem",
            completed: false
        )
        let result = try wait(for: subject.get(Sample.self, path: "/todos/1"))
        XCTAssertEqual(expected, result)
    }

    ///
    /// Calling the GET method on a URL should return an error when the data returned by the URL does
    /// not match the expected format.
    ///
    func testGetShouldFailWhenWebRequestReturnsNonConformingData() throws {
        let subject = JSONTransport(
            url: URL(string: "https://jsonplaceholder.typicode.com")!
        )
        XCTAssertThrowsError(try wait(for: subject.get(NonConformingType.self, path: "/todos/1")))
    }
    
    ///
    /// Calling the GET method on a URL should fail if the URL resource does not exist.
    ///
    func testGetShouldFailWhenWebRequestCallsNonexistingURL() {
        let subject = JSONTransport(
            url: URL(string: "https://nowhere.example.org")!
        )
        XCTAssertThrowsError(try wait(for: subject.get(Sample.self, path: "/todos/1")))
    }
}
