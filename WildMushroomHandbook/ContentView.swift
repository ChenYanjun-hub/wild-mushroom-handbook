//
//  ContentView.swift
//  WildMushroomHandbook
//
//  主视图 - Tab 导航（Figma Make 设计）
//

import SwiftUI

struct ContentView: View {
    @StateObject private var handbookStorage = HandbookStorageService.shared
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "首页"
        case collection = "图鉴"
        case stats = "统计"
        case profile = "我的"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .collection: return "book.fill"
            case .stats: return "chart.bar.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            // 渐变背景
            GradientBackground()

            VStack(spacing: 0) {
                // iOS 状态栏区域
                HStack {
                    Text("9:41")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textTertiary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "signal.cellular.3")
                        Image(systemName: "wifi")
                        Image(systemName: "battery.100")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 8)

                // 主内容区
                Group {
                    switch selectedTab {
                    case .home:
                        HomeScreenView()
                    case .collection:
                        CollectionScreenView()
                    case .stats:
                        StatsScreenView()
                    case .profile:
                        ProfileScreenView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 底部导航栏
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
        .environmentObject(handbookStorage)
    }
}

// MARK: - 底部导航栏
struct BottomTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                TabButton(
                    icon: tab.icon,
                    label: tab.rawValue,
                    isActive: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(.ultraThinMaterial)
        .background(Color.white.opacity(0.3))
        .overlay(
            Rectangle()
                .fill(Color.borderLight)
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

// MARK: - Tab 按钮
struct TabButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isActive ? .textPrimary : .textQuaternary)

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(isActive ? .textPrimary : .textQuaternary)

                // 激活指示器
                Circle()
                    .fill(Color.black)
                    .frame(width: 4, height: 4)
                    .opacity(isActive ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 首页视图
struct HomeScreenView: View {
    @State private var showAddMenu = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 标题区
                VStack(alignment: .leading, spacing: 4) {
                    Text("MOO-菇手帐")
                        .font(.appTitle(36))
                        .foregroundColor(.textPrimary)
                    Text("野生菌数字手帐与防御性鉴别App")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    Text("记录每一次采菌之旅")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)

                // 添加按钮
                AddFindButton(showMenu: $showAddMenu)
                    .padding(.bottom, 32)

                // 最近收集图片预览
                RecentPhotosPreview()
                    .padding(.bottom, 32)

                // 最近记录标题
                Text("Recent Discoveries")
                    .font(.system(size: 12))
                    .foregroundColor(.textTertiary)
                    .tracking(1.5)
                    .padding(.bottom, 16)

                // 最近记录列表
                VStack(spacing: 20) {
                    ForEach(sampleRecords) { record in
                        RecordCard(record: record)
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - 添加发现按钮
struct AddFindButton: View {
    @Binding var showMenu: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showMenu.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                    Text("add new find")
                        .font(.appTitle(16))
                        .lowercase()
                }
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.cardBackground)
                .cornerRadius(999)
                .overlay(
                    Capsule()
                        .stroke(Color.borderMedium, lineWidth: 1)
                )
            }

            // 弹出菜单
            if showMenu {
                VStack(spacing: 0) {
                    MenuButtonRow(
                        icon: "camera.fill",
                        title: "拍照",
                        subtitle: "即时记录发现的野生菌",
                        gradient: [.gradientEmerald, .gradientLime]
                    )

                    Divider()
                        .background(Color.borderLight)

                    MenuButtonRow(
                        icon: "photo.fill",
                        title: "从相册上传",
                        subtitle: "选择已有的野生菌照片",
                        gradient: [.gradientPurple, .gradientPink]
                    )
                }
                .background(Color.white.opacity(0.9))
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 4)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
    }
}

// MARK: - 菜单按钮行
struct MenuButtonRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]

    var body: some View {
        Button {
            // TODO: 实现功能
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 40, height: 40)
                    .cornerRadius(12)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appTitle(16))
                        .foregroundColor(.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textQuaternary)
            }
            .padding(16)
        }
    }
}

// MARK: - 最近图片预览
struct RecentPhotosPreview: View {
    var body: some View {
        HStack(spacing: -20) {
            ForEach(0..<5, id: \.self) { index in
                ZStack {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1509773896068-7fd415d91e2e?w=200&h=200&fit=crop")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.8), lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .rotationEffect(.degrees(Double(index - 2) * 3))
                .offset(x: CGFloat(index - 2) * 15)
            }
        }
        .frame(height: 120)
    }
}

// MARK: - 记录卡片
struct RecordCard: View {
    let record: MushroomRecord

    var body: some View {
        ZStack {
            // 渐变装饰背景
            Color.clear
                .background(
                    LinearGradient(
                        colors: [.gradientEmerald, .gradientYellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 40)
                    .opacity(0.2)
                )

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.date)
                            .font(.appTitle(12))
                            .foregroundColor(.textTertiary)
                        Text(record.name)
                            .font(.appTitle(24))
                            .foregroundColor(.textPrimary)
                        Text(record.latinName)
                            .font(.system(size: 14))
                            .italic()
                            .foregroundColor(.textTertiary)
                    }

                    Spacer()

                    Text(record.emoji)
                        .font(.system(size: 40))
                }

                HStack(spacing: 16) {
                    Label(record.location, systemImage: "mappin")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                    Label(record.weather, systemImage: "cloud")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(24)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.card)
                    .stroke(Color.borderLight, lineWidth: 1)
            )
        }
    }
}

// MARK: - 数据模型
struct MushroomRecord: Identifiable {
    let id = UUID()
    let name: String
    let latinName: String
    let date: String
    let location: String
    let weather: String
    let emoji: String
}

let sampleRecords = [
    MushroomRecord(name: "松茸", latinName: "Tricholoma matsutake", date: "04 / 26", location: "云南香格里拉", weather: "晴朗", emoji: "🍄"),
    MushroomRecord(name: "羊肚菌", latinName: "Morchella esculenta", date: "04 / 20", location: "四川阿坝", weather: "多云", emoji: "🍄")
]

// MARK: - 图鉴页视图
struct CollectionScreenView: View {
    let mushrooms = [
        (name: "松茸", emoji: "🍄", count: 3),
        (name: "羊肚菌", emoji: "🍄", count: 5),
        (name: "牛肝菌", emoji: "🍄", count: 2),
        (name: "鸡枞菌", emoji: "🍄", count: 4),
        (name: "黑松露", emoji: "🍄", count: 1),
        (name: "竹荪", emoji: "🍄", count: 6)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 标题
                VStack(alignment: .leading, spacing: 4) {
                    Text("MOO-菇图鉴")
                        .font(.appTitle(36))
                        .foregroundColor(.textPrimary)
                    Text("已收集 \(mushrooms.count) 种野生菌")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)

                // 网格
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(mushrooms, id: \.name) { mushroom in
                        MushroomCard(name: mushroom.name, emoji: mushroom.emoji, count: mushroom.count)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - 蘑菇卡片
struct MushroomCard: View {
    let name: String
    let emoji: String
    let count: Int

    var body: some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 48))

            Text(name)
                .font(.appTitle(20))
                .foregroundColor(.textPrimary)

            Text("\(count) 次")
                .font(.system(size: 12))
                .foregroundColor(.textTertiary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.6))
                .cornerRadius(999)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .stroke(Color.borderLight, lineWidth: 1)
        )
    }
}

// MARK: - 统计页视图
struct StatsScreenView: View {
    let mushrooms = [
        (name: "竹荪", count: 6),
        (name: "羊肚菌", count: 5),
        (name: "鸡枞菌", count: 4)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 标题
                VStack(alignment: .leading, spacing: 4) {
                    Text("MOO-菇统计")
                        .font(.appTitle(36))
                        .foregroundColor(.textPrimary)
                    Text("你的采菌成就一览")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)

                // 本月采集卡片
                VStack(alignment: .leading, spacing: 8) {
                    Text("本月采集")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                    Text("21")
                        .font(.appTitle(48))
                        .foregroundColor(.textPrimary)
                    Text("↑ 比上月多 35%")
                        .font(.system(size: 14))
                        .foregroundColor(.gradientEmerald)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
                .padding(.bottom, 16)

                // 统计网格
                HStack(spacing: 16) {
                    StatCard(title: "菌类种类", value: "6")
                    StatCard(title: "探索地点", value: "12")
                }
                .padding(.bottom, 24)

                // 最多收集
                VStack(alignment: .leading, spacing: 20) {
                    Text("Most collected fungi")
                        .font(.appTitle(18))
                        .foregroundColor(.textPrimary)

                    ForEach(mushrooms, id: \.name) { mushroom in
                        HStack(spacing: 12) {
                            Text("🍄")
                                .font(.system(size: 24))

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(mushroom.name)
                                        .font(.appTitle(14))
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                    Text("\(mushroom.count) 次")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textSecondary)
                                }

                                // 进度条
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Color.black.opacity(0.05)
                                            .cornerRadius(4)

                                        LinearGradient(
                                            colors: [.gradientEmerald, .gradientLime, .gradientYellow],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .frame(width: geo.size.width * CGFloat(mushroom.count) / 6)
                                        .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.card)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
            Text(value)
                .font(.appTitle(36))
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .stroke(Color.borderLight, lineWidth: 1)
        )
    }
}

// MARK: - 个人中心视图
struct ProfileScreenView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 个人信息卡片
                ProfileHeader()

                // 成就区域
                AchievementsSection()

                // 设置列表
                SettingsSection()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}

// MARK: - 个人信息头部
struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            // 头像
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(Color.borderLight, lineWidth: 2)
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.textQuaternary)
            }

            Text("MOO-菇探索者")
                .font(.appTitle(28))
                .foregroundColor(.textPrimary)

            Text("野生菌数字手帐与防御性鉴别")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)

            Text("Mushroom Forager")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)

            // 统计
            HStack(spacing: 32) {
                ProfileStat(value: "21", label: "记录")
                ProfileStat(value: "6", label: "种类")
                ProfileStat(value: "12", label: "地点")
            }
            .padding(.top, 8)
        }
        .padding(32)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.card)
                .stroke(Color.borderLight, lineWidth: 1)
        )
    }
}

// MARK: - 个人统计
struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.appTitle(24))
                .foregroundColor(.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - 成就区域
struct AchievementsSection: View {
    @State private var expanded = false

    let achievements = [
        (icon: "🏆", label: "首次采集", unlocked: true),
        (icon: "⭐", label: "收集达人", unlocked: true),
        (icon: "🌟", label: "探索者", unlocked: true),
        (icon: "💎", label: "稀有菌类", unlocked: false),
        (icon: "🎯", label: "完美记录", unlocked: false),
        (icon: "🔥", label: "连续打卡", unlocked: true),
        (icon: "📸", label: "摄影师", unlocked: true),
        (icon: "🗺️", label: "地图大师", unlocked: false),
        (icon: "🌈", label: "多样收集", unlocked: true),
        (icon: "📚", label: "知识渊博", unlocked: false),
        (icon: "⏰", label: "早起鸟儿", unlocked: false),
        (icon: "🌙", label: "夜猫子", unlocked: false)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 12))
                    .foregroundColor(.textTertiary)
                    .tracking(1.5)

                Spacer()

                Button {
                    withAnimation {
                        expanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(expanded ? "收起" : "更多")
                            .font(.appTitle(14))
                            .foregroundColor(.textTertiary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                            .foregroundColor(.textTertiary)
                    }
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(achievements.prefix(expanded ? 12 : 6), id: \.label) { achievement in
                    VStack(spacing: 8) {
                        Text(achievement.icon)
                            .font(.system(size: 28))
                            .opacity(achievement.unlocked ? 1 : 0.3)
                        Text(achievement.label)
                            .font(.system(size: 11))
                            .foregroundColor(achievement.unlocked ? .textPrimary : .textQuaternary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(achievement.unlocked ? Color.cardBackground : Color.white.opacity(0.2))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.borderLight, lineWidth: 1)
                    )
                }
            }

            // 进度条
            VStack(spacing: 8) {
                Text("已解锁 \(achievements.filter { $0.unlocked }.count) / \(achievements.count)")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.black.opacity(0.05)
                            .cornerRadius(4)

                        LinearGradient(
                            colors: [.gradientEmerald, .gradientLime, .gradientYellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * CGFloat(achievements.filter { $0.unlocked }.count) / CGFloat(achievements.count))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

// MARK: - 设置区域
struct SettingsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Settings")
                .font(.system(size: 12))
                .foregroundColor(.textTertiary)
                .tracking(1.5)

            // 通用设置
            VStack(spacing: 0) {
                SettingsRow(icon: "globe", title: "语言设置")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "bell", title: "通知提醒")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "paintpalette", title: "主题外观")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "speaker.wave.2", title: "声音效果")
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderLight, lineWidth: 1)
            )

            // 隐私与条款
            VStack(spacing: 0) {
                SettingsRow(icon: "shield", title: "隐私政策")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "doc.text", title: "用户协议")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "exclamationmark.triangle", title: "免责声明")
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderLight, lineWidth: 1)
            )

            // 反馈
            VStack(spacing: 0) {
                SettingsRow(icon: "message", title: "问题反馈")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "heart", title: "功能建议")
                Divider().background(Color.borderLight)
                SettingsRow(icon: "rosette", title: "关于我们")
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderLight, lineWidth: 1)
            )

            // 退出登录
            Button {
                // TODO: 退出登录
            } label: {
                Text("sign out")
                    .font(.appTitle(16))
                    .foregroundColor(.textTertiary)
                    .lowercase()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(999)
            .overlay(
                Capsule()
                    .stroke(Color.borderMedium, lineWidth: 1)
            )
        }
    }
}

// MARK: - 设置行
struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        Button {
            // TODO: 实现功能
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.textTertiary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textQuaternary)
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    ContentView()
}
