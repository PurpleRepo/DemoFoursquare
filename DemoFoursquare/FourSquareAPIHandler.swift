//
//  FourSquareAPIHandler.swift
//  DemoFoursquare
//
//  Created by Andrew Bailey on 11/13/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import Foundation


let ClientID                = "RAGVBCWW14FXLMWOYWCPUIGM4BEGUMGPMT1EUZG5MVTFQMTD"
let ClientSecret            = "EXFZSJWZK0KODJZHUMK3EXEPTFQ3U4OWX1JPIJNFEN20X0II"
let FOURSQUARE_URL_FORMAT   = "https://api.foursquare.com/v2/venues/search?near=%@&location&query=%@&client_id=%@&client_secret=%@&v=20130815"

class FourSquareAPIHandler: NSObject {
    
    static let shared = FourSquareAPIHandler.init(clientID: ClientID, clientSecret: ClientSecret)
    
    private let clientID: String
    private let clientSecret: String
    
    private init(clientID: String, clientSecret: String){
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    private func getURLString(format: String, searchLocation: String, searchCriteria: String) -> String {
        return String(format: format, searchLocation, searchCriteria, clientID, clientSecret)
    }
    
    func getVenues(around cityLocation: String, for searchCriteria: String, completion: @escaping (Array<Venue>?, Error?) -> ()) {
        var venues = Array<Venue>()
        let stringURL = getURLString(format: FOURSQUARE_URL_FORMAT, searchLocation: cityLocation, searchCriteria: searchCriteria)
        print(stringURL)
        if let url = URL(string: stringURL){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Dictionary<String, Any>> {
                            print("\(cityLocation) for \(searchCriteria)")
                            print(jsonResult)
                            guard let venueArray = jsonResult["response"]?["venues"] as? Array<Dictionary<String, Any>> else {
                                return
                            }
                            for venue in venueArray {
                                if let venueName = venue["name"] as? String, let venueLocationInformation = venue["location"] as? Dictionary<String, Any> {
                                    if let venueAddress = venueLocationInformation["address"] as? String {
                                        venues.append(Venue(name: venueName, address: venueAddress))
                                    }
                                }
                            }
                            completion(venues, nil)
                        }
                    } catch {
                        print("Unexpected JSON data formatting.")
                        completion(nil, error)
                    }
                } else {
                    print(error)
                    completion(nil, error)
                }
            }.resume()
        }
    }
}
