//
//  HandbookEntryDetailView.swift
//  WildMushroomHandbook
//
//  手帐记录详情页
//

import SwiftUI

struct HandbookEntryDetailView: View {
    let entry: HandbookEntry

    @Environment(\.dismiss) private var dismiss
    @State private var showDangerAlert = false
    @State private var isUnlocked = false

    private var isForbidden: Bool {
        entry.riskLevel == .critical
    }

    var body: some View {
        ZStack {
            // 背景
            if isForbidden && !isUnlocked {
                Color.red.opacity(0.1)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.96, blue: 0.93)
                    .ignoresSafeArea()
            }

            if isForbidden && !isUnlocked {
                // 禁忌记录锁定视图
                forbiddenLockView
            } else {
                // 正常详情视图
                detailContent
            }
        }
        .navigationTitle(entry.commonName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("危险警告", isPresented: $showDangerAlert) {
            Button("取消", role: .cancel) {}
            Button("我已知晓风险", role: .destructive) {
                isUnlocked = true
            }
        } message: {
            Text("该物种具有致命毒性，确定要查看详情吗？")
        }
    }

    // MARK: - 禁忌锁定视图

    private var forbiddenLockView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 锁定图标
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)
            }

            VStack(spacing: 8) {
                Text("禁忌档案")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)

                Text("此物种具有致命毒性")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            Button {
                showDangerAlert = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("滑动解锁查看详情")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - 详情内容

    private var detailContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 贴纸展示区
                stickerSection

                // 物种信息
                speciesInfoSection

                // 采集信息
                collectionInfoSection

                // 关键特征
                featuresSection
            }
            .padding()
        }
    }

    // MARK: - 贴纸展示区

    private var stickerSection: some View {
        ZStack {
            if isForbidden {
                Color.black
                    .cornerRadius(16)
            } else {
                Color.white
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }

            VStack(spacing: 12) {
                // 尝试加载贴纸图片
                if let imagePath = entry.stickerImagePath,
                   let image = ImageCacheService.shared.loadImage(from: imagePath) {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()

                        // 禁忌记录添加危险覆盖
                        if isForbidden {
                            VStack {
                                HStack {
                                    dangerTape
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                } else {
                    // 占位图
                    VStack(spacing: 12) {
                        Image(systemName: isForbidden ? "skull.fill" : "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(isForbidden ? .red : .green.opacity(0.5))

                        Text(entry.commonName)
                            .font(.headline)
                            .foregroundStyle(isForbidden ? .red : .primary)
                    }
                    .frame(height: 200)
                }

                // 学名标签
                Text(entry.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
        }
        .frame(height: isForbidden ? 260 : 250)
    }

    private var dangerTape: some View {
        Text("⚠️ DANGER ⚠️")
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.yellow.opacity(0.8))
            .rotationEffect(.degrees(-5))
    }

    // MARK: - 物种信息区

    private var speciesInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("物种信息")

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(label: "俗名", value: entry.commonName)
                    infoRow(label: "学名", value: entry.scientificName)
                    infoRow(label: "稀有度", value: entry.rarityLevel.displayName)
                    infoRow(label: "风险等级", value: entry.riskLevel.description, isDanger: isForbidden)
                }

                Spacer()

                // 稀有度徽章
                rarityBadge
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    private var rarityBadge: some View {
        VStack {
            Text(entry.rarityLevel.displayName)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(rarityColor)
                .foregroundStyle(.white)
                .cornerRadius(8)

            if isForbidden {
                Image(systemName: "skull.fill")
                    .font(.title)
                    .foregroundStyle(.red)
                    .padding(.top, 8)
            }
        }
    }

    private var rarityColor: Color {
        switch entry.rarityLevel {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .legendary: return .orange
        }
    }

    // MARK: - 采集信息区

    private var collectionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("采集信息")

            HStack(spacing: 20) {
                collectionInfoItem(
                    icon: "calendar",
                    label: "日期",
                    value: formatDate(entry.collectionDate)
                )

                collectionInfoItem(
                    icon: "mountain.2.fill",
                    label: "海拔",
                    value: entry.altitude
                )

                collectionInfoItem(
                    icon: "map.fill",
                    label: "地区",
                    value: entry.region
                )
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    private func collectionInfoItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 关键特征区

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("关键特征")

            FlowLayout(spacing: 8) {
                ForEach(entry.keyFeatures, id: \.self) { feature in
                    Text(feature)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    // MARK: - 辅助视图

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.secondary)
    }

    private func infoRow(label: String, value: String, isDanger: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isDanger ? .red : .primary)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 流式布局

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.dimensions(in: .unspecified).width + spacing
            }
            y += row.height + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRowItems: [LayoutSubview] = []
        var currentX: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && !currentRowItems.isEmpty {
                rows.append(Row(items: currentRowItems))
                currentRowItems = []
                currentX = 0
            }

            currentRowItems.append(subview)
            currentX += size.width + spacing
        }

        if !currentRowItems.isEmpty {
            rows.append(Row(items: currentRowItems))
        }

        return rows
    }

    struct Row {
        let items: [LayoutSubview]
        var height: CGFloat {
            items.map { $0.dimensions(in: .unspecified).height }.max() ?? 0
        }
    }
}

#Preview {
    NavigationStack {
        HandbookEntryDetailView(entry: HandbookEntry(
            identificationId: "test",
            speciesId: "mush_001",
            commonName: "美味牛肝菌",
            scientificName: "Boletus edulis",
            rarityLevel: .common,
            riskLevel: .normal,
            originalImagePath: nil,
            stickerImagePath: nil,
            collectionDate: Date(),
            altitude: "2400m",
            region: "YUNNAN",
            keyFeatures: ["棕色菌盖", "白色菌肉", "网状菌柄"]
        ))
    }
}
