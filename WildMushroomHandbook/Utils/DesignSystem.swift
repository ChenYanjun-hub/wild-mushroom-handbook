//
//  DesignSystem.swift
//  WildMushroomHandbook
//
//  Figma Make 设计系统 - 颜色、字体、样式
//

import SwiftUI

// MARK: - 颜色系统
extension Color {
    // 背景色
    static let appBackground = Color(hex: "F5F5F0")

    // 渐变色
    static let gradientEmerald = Color(hex: "34D399")  // emerald-400
    static let gradientLime = Color(hex: "A3E635")     // lime-400
    static let gradientYellow = Color(hex: "FACC15")   // yellow-400
    static let gradientOrange = Color(hex: "FB923C")   // orange-300
    static let gradientPurple = Color(hex: "C084FC")   // purple-400
    static let gradientPink = Color(hex: "F472B6")     // pink-400

    // 文字颜色
    static let textPrimary = Color.black
    static let textSecondary = Color(hex: "6B7280")    // gray-500
    static let textTertiary = Color.black.opacity(0.6)
    static let textQuaternary = Color.black.opacity(0.4)

    // 边框颜色
    static let borderLight = Color.black.opacity(0.1)
    static let borderMedium = Color.black.opacity(0.2)

    // 卡片背景
    static let cardBackground = Color.white.opacity(0.4)
    static let cardBackgroundHover = Color.white.opacity(0.6)

    // 成就进度条
    static let progressGradient = LinearGradient(
        colors: [.gradientEmerald, .gradientLime, .gradientYellow],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - 渐变背景
struct GradientBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            // 柔和渐变装饰
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.gradientEmerald, .gradientLime, .gradientYellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 320, height: 384)
                        .blur(radius: 50)
                        .opacity(0.3)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.gradientOrange, .gradientYellow, .gradientLime],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 288, height: 320)
                        .blur(radius: 50)
                        .opacity(0.3)
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - 字体系统
extension Font {
    // 标题字体 - Cormorant Garamond 风格（使用系统衬线字体近似）
    static func appTitle(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif)
    }

    // 正文字体 - Inter 风格（使用系统无衬线字体）
    static func appBody(_ size: CGFloat) -> Font {
        .system(size: size, design: .default)
    }
}

// MARK: - 圆角半径
struct CornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let xlarge: CGFloat = 24
    static let card: CGFloat = 24
    static let button: CGFloat = 999 // 全圆角
}

// MARK: - 间距
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - 卡片样式修饰器
struct CardStyle: ViewModifier {
    var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .background(isHovered ? Color.cardBackgroundHover : Color.cardBackground)
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Color.borderLight, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(isHovered: Bool = false) -> some View {
        modifier(CardStyle(isHovered: isHovered))
    }

    // 玻璃态效果
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.3))
    }
}

// MARK: - Color 扩展：支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 预览
#Preview {
    ZStack {
        GradientBackground()
        VStack {
            Text("MOO-菇手帐")
                .font(.appTitle(36))
            Text("野生菌数字手帐")
                .font(.appBody(16))
                .foregroundColor(.textSecondary)
        }
    }
}
