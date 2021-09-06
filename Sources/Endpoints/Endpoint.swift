#if canImport(Foundation)
import Foundation
#endif

/// A very basic set of parameters that can define a particular API endoint(s)
///
/// Usually, most of network frameworks provide all necessary functionality for http requests building.
/// So this protocol aimed as a declaration of the most basic API parameters which can be easily extended.
public protocol AnyHTTPEndpoint: LosslessStringConvertible {
    /// HTTP Headers
    var headers: HTTP.Headers? { get }
    /// Http method
    var method: HTTP.Method { get }
    /// Base URL of the server.
    /// - NOTE: The best way is making extension with default value.
    var baseURL: String { get }
    /// URL path which is being added to `baseURL`
    var path: String { get }
    /// HTTP request parameters.
    var parameters: [String: Any]? { get }
}

public extension AnyHTTPEndpoint {
    var headers: HTTP.Headers? { nil }
    var parameters: [String: Any]? { nil }
}

// MARK: -

public protocol Endpoint: AnyHTTPEndpoint {
    
    typealias HTTPParameter = HTTP.Parameter
    
    associatedtype Body: HTTPPayload
    
    var body: Body? { get }
}

public extension Endpoint {
    
    var body: Body? { nil }

    var parameters: [String: Any]? {
        let buf = Mirror(reflecting: self).children.compactMap {
            $0.value as? AnyParameterValue
        }.filter {
            $0.kind == .query
        }.map {
            ($0.name, $0.anyValue)
        }
        return Dictionary(uniqueKeysWithValues: buf)
    }
}


// MARK: - Extensions

public extension AnyHTTPEndpoint {
    
    #if canImport(Foundation)
    var url: URL? {
        let r = path.startIndex ..< path.index(path.startIndex, offsetBy: 2)
        let p = path.replacingOccurrences(of: "/", with: "", options: [], range: r)
        if let q = query {
            return URL(string: baseURL)?.appendingPathComponent(p).appendingPathComponent(q)
        } else {
            return URL(string: baseURL)?.appendingPathComponent(p)
        }
    }
    #endif
    
    var urlString: String {
        let r = path.startIndex ..< path.index(path.startIndex, offsetBy: 2)
        let p = path.replacingOccurrences(of: "/", with: "", options: [], range: r)
        return "\(baseURL)/\(p)\(query ?? "")".replacingOccurrences(of: "//", with: "/")
    }
    
    var query: String? {
        parameters?.encodedFor(method: .get)
    }
}

// MARK: - LosslessStringConvertible

extension AnyHTTPEndpoint {
    
    public init?(_ description: String) {
        // FIXME: Implement this
        return nil
    }
    
    public var description: String {
        // FIXME: Add headers & parameters here
        "\(method.rawValue.uppercased()) \(urlString)"
    }
}

