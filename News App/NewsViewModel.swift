//
//  NewsViewModel.swift
//  News App
//
//  Created by Aashish Kapoor on 10/15/24.
//


import Foundation

class NewsViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiKey = "09b0e2004f9944849b7e6c4be86a9506"
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil
        
        // Updated URL for NewsAPI Top Headlines
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching news: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Unexpected server response"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    // Decode the response using your NewsResponse model
                    let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.articles = decodedResponse.articles
                } catch {
                    self.errorMessage = "Error decoding data: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }

}
