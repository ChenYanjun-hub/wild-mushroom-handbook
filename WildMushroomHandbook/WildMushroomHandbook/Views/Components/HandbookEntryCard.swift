//
//  HandbookEntryCard.swift
//  WildMushroomHandbook
//
//  手帐记录卡片组件
//

import SwiftUI

/// 普通记录卡片
struct HandbookEntryCard: View {
    let entry: HandbookEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 贴纸图片区域
            stickerArea

            // 物种信息
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.commonName)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // 采集信息
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(entry.altitude)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var stickerArea: some View {
        ZStack {
            // 占位背景
            Color.gray.opacity(0.1)

            // 尝试加载贴纸图片
            if let imagePath = entry.stickerImagePath,
               let image = ImageCacheService.shared.loadImage(from: imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                // 占位图
                VStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green.opacity(0.5))

                    Text(entry.commonName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // 稀有度标签
            VStack {
                HStack {
                    Spacer()
                    rarityBadge
                }
                Spacer()
            }
            .padding(8)
        }
        .frame(height: 140)
    }

    private var rarityBadge: some View {
        Text(entry.rarityLevel.displayName)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(rarityColor)
            .foregroundStyle(.white)
            .cornerRadius(8)
    }

    private var rarityColor: Color {
        switch entry.rarityLevel {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .legendary: return .orange
        }
    }
}

// MARK: - 禁忌记录卡片

struct ForbiddenEntryCard: View {
    let entry: HandbookEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 贴纸图片区域（带危险覆盖）
            forbiddenStickerArea

            // 物种信息
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.commonName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.red)

                Text(entry.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red, lineWidth: 2)
        )
        .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private var forbiddenStickerArea: some View {
        ZStack {
            // 深色背景
            Color.black

            // 尝试加载贴纸图片
            if let imagePath = entry.stickerImagePath,
               let image = ImageCacheService.shared.loadImage(from: imagePath) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .opacity(0.7)

                    // DANGER 胶带覆盖效果
                    dangerOverlay
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red)

                    Text("危险物种")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            // 危险标签
            VStack {
                HStack {
                    dangerBadge
                    Spacer()
                }
                Spacer()
            }
            .padding(8)
        }
        .frame(height: 140)
    }

    private var dangerOverlay: some View {
        // DANGER 警戒线效果
        GeometryReader { geometry in
            ZStack {
                // 斜条纹背景
                StripePattern()
                    .fill(Color.red.opacity(0.3))

                // DANGER 文字
                Text("DANGER")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.red)
                    .rotationEffect(.degrees(-15))
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private var dangerBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "skull.fill")
                .font(.caption2)
            Text("致命")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red)
        .foregroundStyle(.white)
        .cornerRadius(8)
    }
}

// MARK: - 斜条纹图案

struct StripePattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 20
        let spacing: CGFloat = 10

        for i in stride(from: -rect.height, to: rect.width + rect.height, by: stripeWidth + spacing) {
            path.move(to: CGPoint(x: i, y: rect.height))
            path.addLine(to: CGPoint(x: i + rect.height, y: 0))
        }

        return path
    }
}

#Preview {
    HStack {
        HandbookEntryCard(entry: HandbookEntry(
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
            keyFeatures: ["棕色菌盖"]
        ))

        ForbiddenEntryCard(entry: HandbookEntry(
            identificationId: "test2",
            speciesId: "mush_042",
            commonName: "白毒伞",
            scientificName: "Amanita verna",
            rarityLevel: .common,
            riskLevel: .critical,
            originalImagePath: nil,
            stickerImagePath: nil,
            collectionDate: Date(),
            altitude: "1800m",
            region: "YUNNAN",
            keyFeatures: ["白色菌盖"]
        ))
    }
    .padding()
}
