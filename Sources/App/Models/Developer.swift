//
//  Developer.swift
//  App
//
//  Created by Renaud JENNY on 10/05/2018.
//

import FluentPostgreSQL
import Vapor

struct Developer: PostgreSQLModel {
    var id: Int?
    var name: String
}

extension Developer: Migration { }

extension Developer: Content { }

extension Developer: Parameter { }
