//
//  Extension.swift
//  HomeWork
//
//  Created by Ajay Odedra on 12/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String{
    func countryBy() -> String? {
        return codeToCountry[self]
    }
    func flag() -> String {
        let base : UInt32 = 127397
        var countryCode = self
        countryCode.removeLast()
        var flag = ""
        for scalar in countryCode.unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
        }
        return String(flag)
    }
}

extension URL{
    func append(queryParameters: [String], with pairName:String) -> URL? {
        
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let urlQueryItems = queryParameters.map { value in
            return URLQueryItem(name: pairName, value: value)
        }
        urlComponents.queryItems = urlQueryItems
        return urlComponents.url
    }

}
