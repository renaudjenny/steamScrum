//
//  ReactController.swift
//  App
//
//  Created by Renaud JENNY on 19/05/2018.
//

import Vapor
import HTTP

class ReactController {

    func index(_ req: Request) throws -> Response {
        return req.redirect(to: "/index.html")
    }
}
