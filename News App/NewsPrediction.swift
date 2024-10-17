//
//  NewsPrediction.swift
//  News App
//
//  Created by Aashish Kapoor on 10/15/24.
//
import Foundation

struct NewsPrediction: Codable {
    let prediction: String
    let confidence: Double
}

class NewsPredictionViewModel: ObservableObject {
    @Published var newsPrediction: NewsPrediction?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "yuHy6SPOVecpYLhgYFueCw"
    
    func fetchPrediction(for articleContent: String) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "https://api.anirudhrao.dev/news/predict/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key") // Corrected header
        
        // Corrected JSON body structure
        let jsonBody: [String: Any] = ["text": articleContent]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        // Make the network call
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching prediction: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from server"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(NewsPrediction.self, from: data)
                    self.newsPrediction = decodedResponse
                } catch {
                    self.errorMessage = "Error decoding response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
