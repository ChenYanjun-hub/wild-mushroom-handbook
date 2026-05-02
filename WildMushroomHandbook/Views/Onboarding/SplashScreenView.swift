//
//  SplashScreenView.swift
//  WildMushroomHandbook
//
//  启动动画页面
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showText = false
    @State private var showSubtitle = false
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [.forestDeep, .forestMid],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo 动画
                ZStack {
                    // 外圈光晕
                    Circle()
                        .fill(Color.forestLight.opacity(0.3))
                        .frame(width: 160, height: 160)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0 : 1)

                    // 主圆
                    Circle()
                        .fill(Color.paperCream)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1 : 0.5)
                        .opacity(isAnimating ? 1 : 0)

                    // 图标
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.forestDeep)
                        .scaleEffect(isAnimating ? 1 : 0.3)
                        .opacity(isAnimating ? 1 : 0)
                }

                // 标题
                VStack(spacing: 8) {
                    Text("MOO-菇手帐")
                        .font(.custom("ZCOOL XiaoWei", size: 32))
                        .foregroundColor(.paperCream)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)

                    Text("探索 · 识别 · 收藏")
                        .font(.system(size: 14))
                        .foregroundColor(.paperCream.opacity(0.7))
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                }

                Spacer()

                // 底部版本信息
                Text("v1.0.0 MVP")
                    .font(.system(size: 12))
                    .foregroundColor(.paperCream.opacity(0.5))
                    .opacity(showSubtitle ? 1 : 0)
            }
        }
        .onAppear {
            // 启动动画序列
            withAnimation(.spring(duration: 0.8).delay(0.2)) {
                isAnimating = true
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                showText = true
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
                showSubtitle = true
            }

            // 自动跳转
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isPresented: .constant(true))
}
