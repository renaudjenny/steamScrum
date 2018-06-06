//
//  ReactMiddleware.swift
//  App
//
//  Created by Renaud JENNY on 06/06/2018.
//

// Vapor 3 port by @ajedwards
import Vapor

public final class ReactMiddleware: Middleware, ServiceType {
    public static func makeService(for worker: Container) throws -> ReactMiddleware {
        return try .init(defaultPath: worker.make(DirectoryConfig.self).workDir + "Public/index.html")
    }

    /// Default Path to index.html
    public let defaultPath: String

    public init(defaultPath: String) {
        self.defaultPath = defaultPath
    }

    /// In the event of a not found error thrown from down the middleware chain,
    /// return our single page application
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let response = try next.respond(to: request)
        return response.flatMap { res in
            var isDir: ObjCBool = false
            guard
                request.http.headers.firstValue(name: HTTPHeaderName("X-Requested-With")) != "XMLHttpRequest",
                FileManager.default.fileExists(atPath: self.defaultPath, isDirectory: &isDir),
                !isDir.boolValue,
                res.http.status == .notFound
                else {
                    return response
            }
            return try request.streamFile(at: self.defaultPath)
        }
    }
}
