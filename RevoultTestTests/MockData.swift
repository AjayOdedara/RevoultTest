//
//  MockData.swift
//  RevoultTestTests
//
//  Created by Ajay Odedra on 18/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
@testable import RevoultTest

extension Currencies{
    static func get() -> [Currencies]{
        return [Currencies(name: "INR"),
                Currencies(name: "USD"),
                Currencies(name: "GBP")]
    }
}
