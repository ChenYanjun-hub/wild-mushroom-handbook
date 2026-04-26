//
//  HandbookEntry.swift
//  WildMushroomHandbook
//
//  手帐记录模型 - 本地存储的手帐条目
//

import Foundation
import SwiftUI

/// 手帐记录 - 存储在手帐本中的单条记录
struct HandbookEntry: Codable, Identifiable {
    /// 唯一标识
    let id: UUID
    /// 关联的识别请求ID
    let identificationId: String
    /// 物种ID
    let speciesId: String
    /// 俗名
    let commonName: String
    /// 学名
    let scientificName: String
    /// 稀有程度
    let rarityLevel: RarityLevel
    /// 风险等级
    let riskLevel: RiskLevel
    /// 原始图片路径（本地）
    let originalImagePath: String?
    /// 贴纸图片路径（本地）
    let stickerImagePath: String?
    /// 采集时间
    let collectionDate: Date
    /// 海拔高度
    let altitude: String
    /// 采集地区
    let region: String
    /// 关键特征
    let keyFeatures: [String]
    /// 是否已查看（用于禁忌记录的二次确认）
    var hasBeenViewed: Bool
    /// 创建时间
    let createdAt: Date

    init(
        id: UUID = UUID(),
        identificationId: String,
        speciesId: String,
        commonName: String,
        scientificName: String,
        rarityLevel: RarityLevel,
        riskLevel: RiskLevel,
        originalImagePath: String?,
        stickerImagePath: String?,
        collectionDate: Date,
        altitude: String,
        region: String,
        keyFeatures: [String]
    ) {
        self.id = id
        self.identificationId = identificationId
        self.speciesId = speciesId
        self.commonName = commonName
        self.scientificName = scientificName
        self.rarityLevel = rarityLevel
        self.riskLevel = riskLevel
        self.originalImagePath = originalImagePath
        self.stickerImagePath = stickerImagePath
        self.collectionDate = collectionDate
        self.altitude = altitude
        self.region = region
        self.keyFeatures = keyFeatures
        self.hasBeenViewed = false
        self.createdAt = Date()
    }

    /// 是否为禁忌记录
    var isForbidden: Bool {
        riskLevel == .critical
    }

    /// 所属章节名称
    var chapterName: String {
        riskLevel.handbookChapter
    }
}

// MARK: - 从 MushroomIdentification 创建
extension HandbookEntry {
    /// 从识别结果创建手帐记录
    static func from(
        identification: MushroomIdentification,
        stickerImagePath: String? = nil,
        originalImagePath: String? = nil
    ) -> HandbookEntry {
        let primaryResult = identification.primaryResult!

        // 解析采集时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let collectionDate = dateFormatter.date(from: identification.handbookMetadata.collectionTimestamp) ?? Date()

        return HandbookEntry(
            identificationId: identification.requestId,
            speciesId: primaryResult.speciesId,
            commonName: primaryResult.commonName,
            scientificName: primaryResult.scientificName,
            rarityLevel: primaryResult.rarityLevel,
            riskLevel: identification.riskAssessment.riskLevel,
            originalImagePath: originalImagePath,
            stickerImagePath: stickerImagePath ?? identification.processingResults.stickerAssetUrl,
            collectionDate: collectionDate,
            altitude: identification.handbookMetadata.locationAltitude,
            region: identification.handbookMetadata.region,
            keyFeatures: primaryResult.keyVisualFeatures
        )
    }
}
