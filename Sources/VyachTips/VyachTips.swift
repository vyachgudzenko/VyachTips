// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation

public class URLRequestBuilder {
    
    enum HTTPMethod: String{
        case get = "GET"
        case post = "POST"
    }
    
    private var baseURL: URL?
    private var pathComponents: [String] = []
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var body: Data?
    private var timeout: TimeInterval = 30
    private var boundary: String = "Boundary-\(UUID().uuidString)"
    private var queryItems: [URLQueryItem] = []

    // MARK: - URL / Path
    func setBaseURLString(_ urlString: String) -> URLRequestBuilder {
        self.baseURL = URL(string: urlString)
        return self
    }

    func addPath(_ path: String) -> URLRequestBuilder {
        pathComponents.append(path)
        return self
    }

    func addPathComponents(_ paths: [String]) -> URLRequestBuilder {
        pathComponents.append(contentsOf: paths)
        return self
    }

    func setURL(_ fullURL: String) -> URLRequestBuilder {
        // Для полностью готовых URL
        self.baseURL = URL(string: fullURL)
        return self
    }

    // MARK: - Method, Headers, Timeout
    func setMethod(_ method: HTTPMethod) -> URLRequestBuilder {
        self.method = method
        return self
    }

    func addHeader(key: String, value: String) -> URLRequestBuilder {
        headers[key] = value
        return self
    }

    func setHeaders(_ headers: [String: String]) -> URLRequestBuilder {
        self.headers = headers
        return self
    }

    func setTimeout(_ seconds: TimeInterval) -> URLRequestBuilder {
        self.timeout = seconds
        return self
    }

    // MARK: - Query
    func addQueryParameter(key: String, value: String?) -> URLRequestBuilder {
        guard let value else { return self }
        queryItems.append(URLQueryItem(name: key, value: value))
        return self
    }

    func addQueryParameters(_ params: [String: String?]) -> URLRequestBuilder {
        for (key, value) in params {
            addQueryParameter(key: key, value: value)
        }
        return self
    }

    // MARK: - JSON body
    func setJSONBody<T: Encodable>(_ object: T) -> URLRequestBuilder {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(object) {
            self.body = data
            addHeader(key: "Content-Type", value: "application/json")
        }
        return self
    }
    
    // MARK: - Build request
    func build() throws -> URLRequest {
        guard var baseURL else {
            throw NSError(
                domain: "Network",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Bad URL "]
            )
        }
        
        for component in pathComponents {
            baseURL.appendPathComponent(component)
        }

        if !queryItems.isEmpty {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            if let urlWithQuery = components?.url {
                baseURL = urlWithQuery
            }
        }

        var request = URLRequest(url: baseURL, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}
