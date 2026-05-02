//
//  ProcessingResults.swift
//  WildMushroomHandbook
//
//  图像处理结果模型
//

import Foundation

/// 图像处理结果 - 包含原始图片和贴纸资产
struct ProcessingResults: Codable {
    /// 原始图片URL
    let originalImageUrl: String
    /// 贴纸资产URL（带白边抠图）
    let stickerAssetUrl: String

    enum CodingKeys: String, CodingKey {
        case originalImageUrl = "original_image_url"
        case stickerAssetUrl = "sticker_asset_url"
    }
}
