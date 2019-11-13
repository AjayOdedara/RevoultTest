//
//  DataProvider.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//


import UIKit

/// A simple protocol for classes that are data sources for table or collection views.
protocol DataProvider: class {
    associatedtype Object

    func object(at indexPath: IndexPath) -> Object
    func numberOfItemsInSection(_ section: Int) -> Int
}
