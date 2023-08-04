//
//  ViewController.swift
//  TCApiDemo
//
//  Created by Abdul Mateen on 31/07/2023.
//

import UIKit

struct TrafficCopResponse: Codable {
    var ivtScore: Double
}

class ViewController: UIViewController {

    @IBOutlet weak var callApiButton: UIButton!
    @IBOutlet weak var ivtScoreValue: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBtnPressed(_ sender: Any) {
        callTrafficCopApi()
    }
    
    func getLanguage() -> String {
        if #available(iOS 16.0, *) {
            return NSLocale.current.language.languageCode?.identifier ?? "en"
        } else {
            return NSLocale.current.languageCode ?? "en"
        }
    }
    
    func getTimeZoneOffset() -> Int {
        let date = Date().timeIntervalSince1970
        let timeZoneOffset = TimeZone.current.secondsFromGMT(for: Date())
        let minutesOffset = Int(timeZoneOffset / 60)
        return -minutesOffset
    }
    
    func getBundleId() -> String {
        return "com.exampleios.id"
    }
    
    func callTrafficCopApi() {
        let url = URL(string: "https://tc.pubguru.net/v1")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        let requestData: [String: Any] = [
            "appId": getBundleId(),
            "navigatorLanguage": getLanguage(),
            "timezoneOffset": getTimeZoneOffset()
        ]
        
        do {
            // Convert the data to JSON format
            let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])

            // Create the URL request
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Token ADD_TOKEN_HERE", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            
            print("Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8))")

            // Create the URLSession
            let session = URLSession.shared

            // Create the data task
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let trafficCopResponse = try JSONDecoder().decode(TrafficCopResponse.self, from: data)
                    
                    print("Response data:\n \(trafficCopResponse)")
                    print("IVT Score:\n \(trafficCopResponse.ivtScore)")
                    DispatchQueue.main.async {
                        self.ivtScoreValue.text = String( trafficCopResponse.ivtScore)
                    }

                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }

            // Start the data task
            task.resume()
        } catch {
            // Print error
            print("Error creating JSON data: \(error.localizedDescription)")
        }
        
    }
}

