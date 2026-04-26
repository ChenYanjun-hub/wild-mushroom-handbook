//
//  OnboardingData.swift
//  WildMushroomHandbook
//
//  引导页数据模型
//

import Foundation
import SwiftUI

/// 引导页数据
struct OnboardingPage: Identifiable {
    let id: String
    let type: PageType
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let accentColor: Color

    enum PageType {
        case welcome
        case feature
        case warning
        case complete
    }
}

// MARK: - 引导页数据

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: "welcome",
            type: .welcome,
            title: "野生菌手帐",
            subtitle: "记录每一次与自然的相遇",
            description: "探索 · 识别 · 收藏",
            iconName: "leaf.fill",
            accentColor: .forestDeep
        ),
        OnboardingPage(
            id: "identify",
            type: .feature,
            title: "智能识别",
            subtitle: "一拍即知",
            description: "拍摄野生菌照片，AI 即刻识别物种，并提供专业的毒性风险评估",
            iconName: "camera.fill",
            accentColor: .forestLight
        ),
        OnboardingPage(
            id: "defend",
            type: .warning,
            title: "防御性预警",
            subtitle: "安全第一",
            description: "致命毒菌自动触发警告，滑动确认后才能查看详情，保护你和家人",
            iconName: "shield.lefthalf.filled",
            accentColor: .dangerRed
        ),
        OnboardingPage(
            id: "collect",
            type: .feature,
            title: "数字手帐",
            subtitle: "贴纸收藏",
            description: "每一次识别都是一张精美贴纸，构建你的专属野生菌图谱",
            iconName: "book.fill",
            accentColor: .accentGold
        )
    ]
}

// MARK: - 颜色扩展

extension Color {
    static let forestDeep = Color(red: 0.102, green: 0.184, blue: 0.137)
    static let forestMid = Color(red: 0.176, green: 0.290, blue: 0.243)
    static let forestLight = Color(red: 0.290, green: 0.486, blue: 0.349)
    static let forestPale = Color(red: 0.561, green: 0.725, blue: 0.588)

    static let paperCream = Color(red: 0.961, green: 0.945, blue: 0.910)
    static let paperWarm = Color(red: 0.922, green: 0.894, blue: 0.831)
    static let paperAged = Color(red: 0.851, green: 0.816, blue: 0.749)

    static let accentRust = Color(red: 0.710, green: 0.322, blue: 0.235)
    static let accentGold = Color(red: 0.788, green: 0.659, blue: 0.298)

    static let dangerRed = Color(red: 0.753, green: 0.224, blue: 0.169)
    static let dangerPale = Color(red: 0.961, green: 0.718, blue: 0.694)
}
