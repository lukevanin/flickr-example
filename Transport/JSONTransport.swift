//
//  JSONTransport.swift
//  Transport
//
//  Created by Luke Van In on 2021/06/16.
//

import Foundation
import Combine


///
/// Interacts with a REST API that encodes requests and responses using JSON  formatting.
///
public final class JSONTransport: RESTTransport {
    
    private let url: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        url: URL,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.url = url
        self.session = session
        self.decoder = decoder
    }
    
    public func get<T>(path: String, parameters: [URLQueryItem] = []) -> AnyPublisher<T, Error> where T : Decodable {
        session
            .dataTaskPublisher(
                for: makeGetRequest(
                    path: path,
                    parameters: parameters
                )
            )
            .tryMap { [decoder] data, response in
                try decoder.decode(T.self, from: data)
            }
            .eraseToAnyPublisher()
    }
    
    private func makeGetRequest(path: String, parameters: [URLQueryItem]) -> URLRequest {
        let url = self.url.appendingPathComponent(path)
        #warning("TODO: Handle URL conversion error")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters
        #warning("TODO: Handle URL serialization error")
        let requestURL = components.url!
        let request = URLRequest(url: requestURL)
        return request
    }
}
