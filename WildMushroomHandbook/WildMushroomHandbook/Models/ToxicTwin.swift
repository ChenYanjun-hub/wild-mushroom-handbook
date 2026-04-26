//
//  ToxicTwin.swift
//  WildMushroomHandbook
//
//  相似物种（毒性双子）模型
//

import Foundation

/// 毒性双子 - 与当前识别物种相似的物种
struct ToxicTwin: Codable, Identifiable {
    var id: String { twinId }

    /// 相似物种ID
    let twinId: String
    /// 相似物种名称
    let twinName: String
    /// 辨别要点
    let comparisonPoint: String

    enum CodingKeys: String, CodingKey {
        case twinId = "twin_id"
        case twinName = "twin_name"
        case comparisonPoint = "comparison_point"
    }
}
