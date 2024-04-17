//
//  ResponseModel.swift
//  ImagesGrid-AP
//
//  Created by Janarthanan Kannan on 17/04/24.
//

import Foundation

//MARK: - Response Model
struct ResponseModel: Codable {
    let id, title, language : String
    let thumbnail: Thumbnail
    let mediaType: Int
    let coverageURL: String
    let publishedAt, publishedBy: String
    let backupDetails: BackupDetails?
}


//MARK: - Backup Details
struct BackupDetails: Codable {
    let pdfLink, screenshotURL: String
}


//MARK: - Thumbnail
struct Thumbnail: Codable {
    let id: String
    let version: Int
    let domain: String
    let basePath, key: String
    let qualities: [Int]
    let aspectRatio: Int
}
