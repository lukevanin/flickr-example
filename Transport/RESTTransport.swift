//
//  Protocols.swift
//  Transport
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine


///
/// Abstract interface for REST transports.
///
public protocol RESTTransport {
    func get<T>(path: String, parameters: [URLQueryItem]) -> AnyPublisher<T, Error> where T: Decodable
}
