//
//  WildMushroomHandbookApp.swift
//  WildMushroomHandbook
//
//  App 入口文件
//

import SwiftUI

@main
struct WildMushroomHandbookApp: App {
    @StateObject private var handbookStorage = HandbookStorageService.shared

    // 启动页和引导页状态
    @State private var showSplash = true
    @State private var showOnboarding = false

    // 是否首次启动
    private let hasSeenOnboardingKey = "has_seen_onboarding"
    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主内容
                ContentView()
                    .environmentObject(handbookStorage)

                // 启动页（首次显示）
                if showSplash {
                    SplashScreenView(isPresented: $showSplash)
                        .transition(.opacity)
                        .onDisappear {
                            // 启动页消失后检查是否需要显示引导页
                            if !hasSeenOnboarding {
                                showOnboarding = true
                            }
                        }
                }

                // 引导页（首次启动时显示）
                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .transition(.opacity)
                        .onDisappear {
                            // 标记已看过引导页
                            UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)
                        }
                }
            }
        }
    }
}
