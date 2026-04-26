//
//  IdentificationResult.swift
//  WildMushroomHandbook
//
//  识别结果模型
//

import Foundation

/// 单个物种识别结果
struct IdentificationResult: Codable, Identifiable {
    var id: String { speciesId }

    /// 物种ID
    let speciesId: String
    /// 俗名
    let commonName: String
    /// 学名
    let scientificName: String
    /// 匹配置信度 (0.0 - 1.0)
    let matchProbability: Double
    /// 稀有程度
    let rarityLevel: RarityLevel
    /// 关键视觉特征
    let keyVisualFeatures: [String]
    /// 毒性双子（相似物种）
    let toxicTwins: [ToxicTwin]?

    enum CodingKeys: String, CodingKey {
        case speciesId = "species_id"
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case matchProbability = "match_probability"
        case rarityLevel = "rarity_level"
        case keyVisualFeatures = "key_visual_features"
        case toxicTwins = "toxic_twins"
    }
}

/// 稀有程度枚举
enum RarityLevel: String, Codable {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case legendary = "LEGENDARY"

    var displayName: String {
        switch self {
        case .common: return "常见"
        case .uncommon: return "不常见"
        case .rare: return "稀有"
        case .legendary: return "传奇"
        }
    }
}
