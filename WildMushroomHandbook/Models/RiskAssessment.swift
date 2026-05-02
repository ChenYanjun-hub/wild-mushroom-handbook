//
//  RiskAssessment.swift
//  WildMushroomHandbook
//
//  风险评估模型
//

import Foundation

/// 风险评估结果
struct RiskAssessment: Codable {
    /// 风险等级
    let riskLevel: RiskLevel
    /// 是否疑似有毒
    let isToxicSuspected: Bool
    /// 系统警告信息
    let systemWarning: String

    enum CodingKeys: String, CodingKey {
        case riskLevel = "risk_level"
        case isToxicSuspected = "is_toxic_suspected"
        case systemWarning = "system_warning"
    }
}
