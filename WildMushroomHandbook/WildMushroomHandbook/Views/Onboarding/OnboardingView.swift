//
//  OnboardingView.swift
//  WildMushroomHandbook
//
//  引导页主视图
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            // 背景色
            Color.paperCream
                .ignoresSafeArea()

            // 纸张纹理叠加
            PaperTextureOverlay()

            // 内容
            TabView(selection: $currentPage) {
                WelcomePage {
                    withAnimation {
                        currentPage = 1
                    }
                }
                .tag(0)

                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    if page.type != .welcome {
                        FeaturePage(page: page, pageIndex: index)
                            .tag(index)
                    }
                }

                CompletePage {
                    isPresented = false
                }
                .tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // 页面指示器
            if currentPage > 0 && currentPage <= pages.count {
                PageIndicator(
                    totalPages: pages.count,
                    currentPage: currentPage - 1
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 120)
            }

            // 导航按钮
            if currentPage > 0 && currentPage <= pages.count {
                NavigationButtons(
                    onPrevious: {
                        withAnimation {
                            currentPage = max(0, currentPage - 1)
                        }
                    },
                    onNext: {
                        withAnimation {
                            currentPage = min(pages.count + 1, currentPage + 1)
                        }
                    },
                    canGoBack: currentPage > 1
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 纸张纹理叠加

struct PaperTextureOverlay: View {
    var body: some View {
        // 使用 Noise 伪随机纹理
        Color.black
            .opacity(0.02)
            .ignoresSafeArea()
            .blendMode(.multiply)
    }
}

// MARK: - 欢迎页

struct WelcomePage: View {
    let onEnter: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // 装饰贴纸
            HStack {
                StickerDecor(emoji: "🌿", size: 40, rotation: -15)
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 60)

            // 主图标
            ZStack {
                Circle()
                    .fill(Color.forestDeep)
                    .frame(width: 140, height: 140)
                    .shadow(color: Color.forestDeep.opacity(0.3), radius: 8, y: 8)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.paperCream)
            }

            // 标题
            VStack(spacing: 8) {
                Text("野生菌手帐")
                    .font(.custom("ZCOOL XiaoWei", size: 36))
                    .foregroundColor(.forestDeep)
                    .letterSpacing(4)

                Text("记录每一次与自然的相遇")
                    .font(.system(size: 16))
                    .foregroundColor(.forestMid)
                    .letterSpacing(2)
            }

            // 描述
            Text("探索 · 识别 · 收藏")
                .font(.custom("ZCOOL XiaoWei", size: 18))
                .foregroundColor(.accentRust)
                .opacity(0.8)

            Spacer()

            // 开始按钮
            Button(action: onEnter) {
                Text("开始探索")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.paperCream)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(Color.forestDeep)
                    .cornerRadius(30)
                    .shadow(color: Color.forestDeep.opacity(0.3), radius: 4, y: 4)
            }

            Spacer()
                .frame(height: 80)
        }
        .background(
            ZStack {
                // 纸胶带装饰
                WashiTape(color: .forestLight, rotation: 15)
                    .position(x: 40, y: 50)

                WashiTape(color: .accentGold, rotation: -12)
                    .position(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 120)

                // 手写标注
                HandwrittenNote(text: "2026.春")
                    .position(x: UIScreen.main.bounds.width - 60, y: 100)
            }
        )
    }
}

// MARK: - 功能介绍页

struct FeaturePage: View {
    let page: OnboardingPage
    let pageIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            // 步骤指示
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(page.accentColor)
                        .frame(width: 32, height: 32)

                    Text("\(pageIndex)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text("Step \(pageIndex)")
                    .font(.custom("ZCOOL XiaoWei", size: 14))
                    .foregroundColor(page.accentColor.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 60)

            Spacer()

            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(
                        LinearGradient(
                            colors: [page.accentColor.opacity(0.2), Color.paperCream],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: page.accentColor.opacity(0.2), radius: 8, y: 8)
                    .rotationEffect(.degrees(-3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(page.accentColor.opacity(0.2), lineWidth: 3)
                    )

                Image(systemName: page.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(page.accentColor)
            }

            Spacer()

            // 文字区域
            VStack(alignment: .leading, spacing: 12) {
                Text(page.title)
                    .font(.custom("ZCOOL XiaoWei", size: 28))
                    .foregroundColor(.forestDeep)

                Text(page.subtitle)
                    .font(.custom("ZCOOL XiaoWei", size: 18))
                    .foregroundColor(page.accentColor)

                Text(page.description)
                    .font(.system(size: 15))
                    .foregroundColor(.forestMid)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.bottom, 160)
        }
        .background(Color.paperCream)
    }
}

// MARK: - 完成页

struct CompletePage: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.accentGold)
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.forestDeep)
            }

            Text("准备就绪")
                .font(.custom("ZCOOL XiaoWei", size: 32))
                .foregroundColor(.paperCream)

            Text("开启你的野生菌探索之旅吧")
                .font(.system(size: 16))
                .foregroundColor(.paperCream.opacity(0.8))

            Spacer()

            Button(action: onComplete) {
                Text("开始使用")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.forestDeep)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(Color.accentGold)
                    .cornerRadius(30)
            }

            Spacer()
                .frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.forestDeep, .forestMid],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - 装饰组件

struct StickerDecor: View {
    let emoji: String
    let size: CGFloat
    let rotation: Double

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .rotationEffect(.degrees(rotation))
            .opacity(0.15)
    }
}

struct WashiTape: View {
    let color: Color
    let rotation: Double

    var body: some View {
        Rectangle()
            .fill(color.opacity(0.6))
            .frame(width: 80, height: 24)
            .rotationEffect(.degrees(rotation))
            .overlay(
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundColor(.white.opacity(0.3))
            )
    }
}

struct HandwrittenNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.custom("ZCOOL XiaoWei", size: 14))
            .foregroundColor(.accentRust.opacity(0.6))
            .rotationEffect(.degrees(8))
    }
}

// MARK: - 页面指示器

struct PageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.forestDeep : Color.forestLight.opacity(0.4))
                    .frame(
                        width: currentPage == index ? 24 : 8,
                        height: 8
                    )
            }
        }
    }
}

// MARK: - 导航按钮

struct NavigationButtons: View {
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoBack: Bool

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Text("← 上一步")
                    .font(.system(size: 16))
                    .foregroundColor(canGoBack ? .forestMid : .clear)
            }
            .disabled(!canGoBack)

            Spacer()

            Button(action: onNext) {
                Text("继续 →")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.paperCream)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.forestDeep)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
