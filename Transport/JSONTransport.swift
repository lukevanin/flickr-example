//
//  JSONTransport.swift
//  Transport
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine


public final class JSONTransport: RESTTransport {
    
    public func get<T>(path: String, parameters: [URLQueryItem]) -> AnyPublisher<T, Error> where T : Decodable {
        fatalError("Not implemented")
    }
}
