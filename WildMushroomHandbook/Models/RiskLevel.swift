//
//  RiskLevel.swift
//  WildMushroomHandbook
//
//  风险等级枚举
//

import Foundation

/// 风险等级枚举 - 用于标识野生菌的危险程度
enum RiskLevel: String, Codable, CaseIterable {
    /// 无明确风险 - 可安全收录
    case normal = "NORMAL"
    /// 警告级别 - 需谨慎处理
    case warning = "WARNING"
    /// 致命危险 - 需特殊处理（滑动解锁、禁忌收录）
    case critical = "CRITICAL"

    /// 风险等级的中文描述
    var description: String {
        switch self {
        case .normal:
            return "无明确风险"
        case .warning:
            return "潜在风险"
        case .critical:
            return "致命危险"
        }
    }

    /// 是否需要危险态处理
    var requiresDangerHandling: Bool {
        return self == .critical
    }

    /// 对应的手帐章节
    var handbookChapter: String {
        switch self {
        case .normal, .warning:
            return "可食用菌图谱"
        case .critical:
            return "禁忌之地"
        }
    }
}
