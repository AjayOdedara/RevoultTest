//
//  AppServerClient.swift
//  RevoultTest
//
//  Created by Ajay Odedra on 05/11/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation


enum Result<T, U: Error> {
    case success(payload: T)
    case failure(U?)
}

enum EmptyResult<U: Error> {
    case success
    case failure(U?)
}

fileprivate enum WebServiceUrl:String {
    case baseUrl = "https://europe-west1-revolut-230009.cloudfunctions.net/revolut-ios?"
    case pair = "pairs"
    
    struct Files {
        static var currencies = "currencies"
    }
}

// MARK: - AppServerClient
class AppServerClient {
    
    class var sharedInstance: AppServerClient {
        struct Static {
            static let instance: AppServerClient! = AppServerClient()
        }
        return Static.instance
    }
    // MARK: - Get Rates
    enum GetFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
        case serverError = 500
    }

    // MARK: - GetCurrencyPair
    typealias PairResults = [String:Any]
    typealias GetRateResult = Result<PairResults, GetFailureReason>
    typealias GetRateCompletion = (_ result: GetRateResult) -> Void

    func getRates(of pairs:[String], completion: @escaping GetRateCompletion) {
        
        guard let baseUrl = URL(string: WebServiceUrl.baseUrl.rawValue),
            let url = baseUrl.append(queryParameters: pairs, with: WebServiceUrl.pair.rawValue) else {
            print("Error: cannot create URL")
            completion(.failure(GetFailureReason.notFound))
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
            print("\(error?.localizedDescription ?? "error calling GET ")")
            completion(.failure(GetFailureReason.serverError))
            return
          }
          // parse the result as JSON, since that's what the API provides
          do {
            guard let responseData = data, let pairResults = try JSONSerialization.jsonObject(with: responseData, options: [])
              as? PairResults else {
                print("Error: did not receive data")
                print("error trying to convert data to JSON")
                completion(.failure(nil))
                return
            }
            completion(.success(payload: pairResults))
            
          } catch  {
            print("error trying to convert data to JSON = \(error.localizedDescription)")
            completion(.failure(nil))
            return
          }
        }
        
        task.resume()
    }
    
    // MARK: - Get Currencies
    
    typealias GetCurrencyResult = Result<[Currencies], GetFailureReason>
    typealias GetCurrencyCompletion = (_ result: GetCurrencyResult) -> Void
    
    func getCurrency(completion: @escaping GetCurrencyCompletion) {
        if let url = Bundle.main.url(forResource: WebServiceUrl.Files.currencies, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let currencies = object as? [String] {
                    var currencyData = [Currencies]()
                    
                    for item in currencies{
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
