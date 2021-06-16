//
//  JSONTransportTests.swift
//  TransportTests
//
//  Created by Luke Van In on 2021/06/16.
//

import XCTest
@testable import Transport

final class JSONTransportTests: XCTestCase {
    
    ///
    /// Calling the GET method on a URL should return the deserialized contents of the response when the
    /// data matches the expected format.
    ///
    func testGetShouldReturnContentWebRequestReturnsMatchingData() {
        XCTFail("Not implemented")
    }

    ///
    /// Calling the GET method on a URL should return an error when the data returned by the URL does
    /// not match the expected format.
    ///
    func testGetShouldFailWhenWebRequestReturnsNonMatchingData() {
        XCTFail("Not implemented")
    }
    
    ///
    /// Calling the GET method on a URL should fail if the URL resource does not exist.
    ///
    func testGetShouldFailWhenWebRequestCallsNonexistingURL() {
        XCTFail("Not implemented")
    }
}
