import Vapor

struct OldHTML {
    let value: String
}

extension OldHTML: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        return request.eventLoop.makeSucceededFuture(.init(
            status: .ok, headers: headers, body: .init(string: value)
        ))
    }
}
