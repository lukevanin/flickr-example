//
//  XCTestCaseExtensions.swift
//  FlickrWebServiceTests
//
//  Created by Luke Van In on 2021/06/16.
//

import XCTest
import Combine

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
