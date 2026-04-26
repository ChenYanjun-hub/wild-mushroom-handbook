//
//  ContentView.swift
//  WildMushroomHandbook
//
//  主视图 - Tab 导航
//

import SwiftUI

struct ContentView: View {
    @StateObject private var handbookStorage = HandbookStorageService.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 手帐主页
            HandbookMainView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("手帐")
                }
                .tag(0)

            // 相机拍摄
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("拍摄")
                }
                .tag(1)

            // 我的收藏
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(2)
        }
        .accentColor(.green)
        .environmentObject(handbookStorage)
    }
}

#Preview {
    ContentView()
}
