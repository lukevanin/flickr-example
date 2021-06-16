//
//  MockTransport.swift
//  Transport
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine

///
/// Returns a predefined response. Used to replace concrete REST protocol types for testing.
///
public final class MockTransport: RESTTransport {
    
    public typealias Get = (_ path: String, _ parameters: [URLQueryItem]) throws -> String

    public var decoder: JSONDecoder = JSONDecoder()
    public var mockGet: Get?
    
    public init() {
        
    }
    
    public func get<T>(path: String, parameters: [URLQueryItem]) -> AnyPublisher<T, Error> where T : Decodable {
        serialize() { [mockGet] in
            try mockGet!(path, parameters)
        }
    }
    
    private func serialize<T>(operation: @escaping () throws -> String) -> AnyPublisher<T, Error> where T: Decodable {
        Future { [decoder] completion in
            do {
                let string = try operation()
                let data = string.data(using: .utf8)!
                let instance = try decoder.decode(T.self, from: data)
                completion(.success(instance))
            }
            catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
