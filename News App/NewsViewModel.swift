//
//  NewsViewModel.swift
//  News App
//
//  Created by Aashish Kapoor on 10/1/24.
//

import Foundation

class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "pR-3o7OJfy1GjyfTSwALYueUSrRBLC93MSIMGX5WxyRAjFHT"
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil
        
        let urlString = "https://api.currentsapi.services/v1/latest-news?apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error fetching news: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data returned"
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.articles = decodedResponse.news
                } catch {
                    self.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
