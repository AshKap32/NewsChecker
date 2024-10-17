//
//  NewsArticle.swift
//  News App
//
//  Created by Aashish Kapoor on 10/15/24.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsArticle: Codable, Hashable {
    let source: Source
    let author: String?          // Made optional
    let title: String
    let description: String?     // Made optional
    let url: String
    let urlToImage: String?      // Made optional
    let publishedAt: String
    let content: String?         // Made optional
}

struct Source: Codable, Hashable {
    let id: String?              // Made optional
    let name: String
}
