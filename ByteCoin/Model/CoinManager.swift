//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didChangeCoin(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with URLString: String) {
        if let url = URL(string: URLString) {
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didChangeCoin(self, coin: coin)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel?{
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(CoinData.self, from: coinData)
            
            let base = data.asset_id_base
            let quote = data.asset_id_quote
            let currencyRate = data.rate
            
            let coin = CoinModel(baseCurrency: base, quoteCurrency: quote, rate: currencyRate)
            return coin
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
