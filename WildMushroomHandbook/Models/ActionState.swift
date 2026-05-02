//
//  ActionState.swift
//  WildMushroomHandbook
//
//  行为状态模型
//

import Foundation

/// 行为状态 - 系统建议的下一步操作
struct ActionState: Codable {
    /// 需要的行为类型
    let actionRequired: ActionType
    /// 提示信息
    let promptMessage: String

    enum CodingKeys: String, CodingKey {
        case actionRequired = "action_required"
        case promptMessage = "prompt_message"
    }
}

/// 行为类型枚举
enum ActionType: String, Codable {
    /// 无需特殊操作
    case none = "NONE"
    /// 需要滑动解锁确认
    case swipeToUnlock = "SWIPE_TO_UNLOCK"
    /// 需要阅读警告
    case readWarning = "READ_WARNING"
    /// 需要专家确认
    case expertConfirmation = "EXPERT_CONFIRMATION"
}
