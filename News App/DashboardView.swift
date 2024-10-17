//
//  DashboardView.swift
//  News App
//
////  Created by Aashish Kapoor on 10/1/24.
import SwiftUI

struct DashboardView: View {
    
    @StateObject private var viewModel = NewsViewModel() 
    @State private var selectedArticle: NewsArticle?
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationSplitView {
            
                List(filteredArticles, id: \.self, selection: $selectedArticle) { article in
                   
                    if article.image != "None" {
                        HStack(alignment: .top, spacing: 12) {
                            // Article Thumbnail Image
                            AsyncImage(url: URL(string: article.image ?? "")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                
                                    .overlay{
                                        ProgressView()
                                    }
                            }
                            
                            
                            // Title and Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text(article.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                    .animation(.spring(), value: searchText)
                                
                                Text(article.description ?? "-")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.4), value: searchText)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText)
            .navigationTitle("Top Headlines")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                viewModel.fetchNews() // Fetch articles when view appears
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Fetching the latest news...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                }
            }
            .refreshable {
                viewModel.fetchNews()
            }
            
        } detail: {
            if let selectedArticle = selectedArticle {
                NewsDetailView(article: selectedArticle)
                    .transition(.slide)
                    .animation(.spring(), value: selectedArticle)
            } else {
                Text("Select an article")
                    .foregroundColor(.gray)
                    .font(.title3)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .transition(.scale)
                    .animation(.easeInOut, value: selectedArticle)
            }
        }
    }
    
    // Computed property to filter articles based on search text
    var filteredArticles: [NewsArticle] {
        if searchText.isEmpty {
            return viewModel.articles
        } else {
            return viewModel.articles.filter { article in
                article.title.contains(searchText) || (article.description?.contains(searchText) ?? false)
            }
        }
    }
}

#Preview {
    DashboardView()
}
