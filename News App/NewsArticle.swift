//
//  NewsArticle.swift
//  News App
//
//  Created by Aashish Kapoor on 10/1/24.
//
import Foundation

struct NewsResponse: Codable {
    let status: String
    let news: [NewsArticle]
}

struct NewsArticle: Codable, Identifiable, Hashable {
    var id: String { url }
    let title: String
    let description: String?
    let url: String
    let published: String
    let author: String?
    let image: String?
}
