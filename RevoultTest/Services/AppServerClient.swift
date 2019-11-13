//
//  AppServerClient.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation

// MARK: - AppServerClient
class AppServerClient {
    
    class var sharedInstance: AppServerClient {
        struct Static {
            static let instance: AppServerClient! = AppServerClient()
        }
        return Static.instance
    }
    
    
    
    // MARK: - GetFruits
    enum GetFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
        case serverError = 500
    }

    // MARK: - GetCurrencyPair
    
    typealias GetRateResult = Result<[CurrrencyRatePairs], GetFailureReason>
    typealias GetRateCompletion = (_ result: GetRateResult) -> Void

    func getRates(of pairs:String, completion: @escaping GetRateCompletion) {
        
        guard let url = URL(string: "https://europe-west1-revolut-230009.cloudfunctions.net/revolut-ios?\(pairs)") else {
          print("Error: cannot create URL")
            let reason = GetFailureReason.notFound
            completion(.failure(reason))
          return
        }
        
        let urlRequest = URLRequest(url: url)
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) {
          (data, response, error) in
          // check for any errors
          guard error == nil else {
            print("error calling GET on /todos/1")
            print(error!)
            let reason = GetFailureReason.serverError
            completion(.failure(reason))
            return
          }
          // make sure we got data
          guard let responseData = data else {
            print("Error: did not receive data")
            return
          }
          // parse the result as JSON, since that's what the API provides
          do {
            
            guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
              as? [String: Any] else {
                print("error trying to convert data to JSON")
                completion(.failure(nil))
                return
            }
            
            var currencyData = [CurrrencyRatePairs]()
            for item in todo{
                currencyData.append(CurrrencyRatePairs(dictionary: item))
            }
            completion(.success(payload: currencyData))
            
          } catch  {
            print("error trying to convert data to JSON")
            print(error.localizedDescription)
            completion(.failure(nil))
            return
          }
        }
        
        task.resume()
    }
    
    // MARK: - GetCurrencies
    
    typealias GetCurrencyResult = Result<[Currencies], GetFailureReason>
    typealias GetCurrencyCompletion = (_ result: GetCurrencyResult) -> Void
    
    func getCurrency(completion: @escaping GetCurrencyCompletion) {
        if let url = Bundle.main.url(forResource: "currencies", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? [String] {
                    var currencyData = [Currencies]()
                    for item in dictionary{
                        currencyData.append(Currencies(name: item))
                    }
                    completion(.success(payload: currencyData))
                }
              } catch {
                   completion(.failure(nil))
              }
        }
    }

}
