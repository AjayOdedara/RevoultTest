//
//  Extension.swift
//  HomeWork
//
//  Created by Ajay Odedra on 04/04/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

// Dialog Alertview

protocol SingleButtonDialogPresenter {
    func presentSingleButtonDialog(alert: SingleButtonAlert)
}

extension SingleButtonDialogPresenter where Self: UIViewController {
    func presentSingleButtonDialog(alert: SingleButtonAlert) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.action.buttonTitle,
                                                style: .default,
                                                handler: { _ in alert.action.handler?() }))
        self.present(alertController, animated: true, completion: nil)
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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

    /*
     usage
     
     if let url = URL(string: "BASE_URL"),
     let appendedURL = url.append(queryParameters: ["GBPEUR", "GBPUSD", "GBPUSD"]) {

         print(appendedURL)
         //Result: BASE_URL?pairs=GBPEUR&pairs=GBPUSD&pairs=GBPUSD
     }
     */
}
