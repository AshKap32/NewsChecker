//
//  NewsDetailView.swift
//  News App
//
//  Created by Aashish Kapoor on 10/1/24.
//


import SwiftUI

struct NewsDetailView: View {
    
    @State var article: NewsArticle
    
    @StateObject private var predictionViewModel = NewsPredictionViewModel()
    @State private var imageReloadKey = UUID()

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.image, let url = URL(string: imageUrl) {
                    AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxHeight: 300)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(12)
                        case .success(let image): image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .shadow(radius: 8)
                                .transition(.scale)
                        case .failure:
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    //To make sure the image loads each time
                    .id(imageReloadKey)
                    .frame(maxWidth: .infinity)
                }
                
                
                Group {
                    Text(article.title)
                        .font(.title)
                        .foregroundStyle(.primary)
                    if let author = article.author {
                        Text("By \(author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                    }
                    if let formattedDate = formatPublishedDate(article.published) {
                        Text("Published on \(formattedDate)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Display the prediction for the article
                predictionSection
                
                // Article Description
                if let description = article.description {
                    Text(description)
                        .font(.body.weight(.medium))
                        .padding(.top, 8)
                        .transition(.opacity)
                }


                // Link to the full article
                if let url = URL(string: article.url) {
                    Link(destination: url) {
                        Text("Read full article")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 16)
                    .transition(.move(edge: .bottom))
                }
            }
            .padding()
        }
      
            
        
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("News Article")
        .onAppear {
            // Generate a new UUID to force image reload when view appears
            imageReloadKey = UUID()

            // Only fetch the prediction if we haven't already fetched it
            if predictionViewModel.newsPrediction == nil {
                let articleText = [article.title, article.description].compactMap { $0 }.joined(separator: " ")
                if !articleText.isEmpty {
                    predictionViewModel.fetchPrediction(for: articleText)
                }
            }
        }
        .animation(.easeInOut, value: predictionViewModel.isLoading)
    }
    
    // THis is where we are checking to see whether or not a given news article is fake or real based on the models prediction and confidence level.
    @ViewBuilder
    private var predictionSection: some View {
        if predictionViewModel.isLoading {
            HStack {
                ProgressView()
                Text("Analyzing news article...")
                    .font(.subheadline)
            }
            .padding(.vertical)
        } else if let prediction = predictionViewModel.newsPrediction {
            HStack(spacing: 16) {
                Image(systemName: prediction.prediction == "Fake News" ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .foregroundStyle(prediction.prediction == "Fake News" ? Color.red : Color.green)
                    .font(.system(size: 24, weight: .bold))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("News Prediction")
                        .font(.headline)
                    
                    Text("This article is likely \(prediction.prediction)")
                        .font(.subheadline)
                    
                    Text("Confidence: \(String(format: "%.2f", prediction.confidence))%")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 5)
        } else if let error = predictionViewModel.errorMessage {
            Text("Error: \(error)")
                .foregroundColor(.red)
                .padding(.vertical)
        }
    }
    
    private func formatPublishedDate(_ dateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: date)
        }
        return nil
    }
}

#Preview {
    NewsDetailView(article: NewsArticle(title: "Test Article", description: "This is he description", url: "https://google.com", published: "Yesterday", author: "Namas", image: ""))
}
