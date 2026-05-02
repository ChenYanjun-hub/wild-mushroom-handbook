//
//  ProfileView.swift
//  WildMushroomHandbook
//
//  个人中心视图
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var handbookStorage: HandbookStorageService

    var body: some View {
        NavigationStack {
            List {
                // 统计概览
                Section("采集统计") {
                    HStack(spacing: 20) {
                        StatItem(
                            icon: "leaf.fill",
                            value: handbookStorage.totalCount,
                            label: "总收录",
                            color: .green
                        )

                        StatItem(
                            icon: "checkmark.shield.fill",
                            value: handbookStorage.normalCount,
                            label: "安全",
                            color: .blue
                        )

                        StatItem(
                            icon: "exclamationmark.triangle.fill",
                            value: handbookStorage.forbiddenCount,
                            label: "禁忌",
                            color: .red
                        )
                    }
                    .padding(.vertical, 8)
                }

                // 成就系统（预留）
                Section("成就") {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text("初学者")
                                .font(.headline)
                            Text("收录第1种野生菌")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if handbookStorage.totalCount >= 1 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text("采集者")
                                .font(.headline)
                            Text("收录10种不同野生菌")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if handbookStorage.uniqueSpeciesCount >= 10 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }

                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(.red)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text("安全卫士")
                                .font(.headline)
                            Text("成功避开1种致命毒菌")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if handbookStorage.forbiddenCount >= 1 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }

                // 开发者选项
                Section("开发者选项") {
                    Button {
                        handbookStorage.preloadMockData()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.blue)
                                .frame(width: 30)
                            Text("加载 Mock 数据")
                        }
                    }

                    Button(role: .destructive) {
                        handbookStorage.clearAll()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .frame(width: 30)
                            Text("清空所有数据")
                        }
                    }
                }

                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 30)
                            Text("使用帮助")
                        }
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
}

// MARK: - 统计项组件

struct StatItem: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environmentObject(HandbookStorageService.shared)
}
