//
//  IdentificationReportView.swift
//  WildMushroomHandbook
//
//  识别报告视图 - 展示识别结果
//

import SwiftUI

struct IdentificationReportView: View {
    let identification: MushroomIdentification
    let onAddToHandbook: () -> Void
    let onDismiss: () -> Void

    @State private var isUnlocked = false
    @State private var showSuccessMessage = false

    private var isDangerous: Bool {
        identification.riskAssessment.riskLevel == .critical
    }

    private var primaryResult: IdentificationResult {
        identification.primaryResult!
    }

    var body: some View {
        ZStack {
            // 背景
            if isDangerous && !isUnlocked {
                Color.red.opacity(0.15)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.96, blue: 0.93)
                    .ignoresSafeArea()
            }

            if isDangerous && !isUnlocked {
                // 危险物种锁定视图
                dangerLockView
            } else {
                // 正常报告视图
                reportContent
            }
        }
        .alert("已加入手帐", isPresented: $showSuccessMessage) {
            Button("好的") {
                onDismiss()
            }
        } message: {
            Text("\(primaryResult.commonName)已成功收录到手帐")
        }
    }

    // MARK: - 危险锁定视图

    private var dangerLockView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 危险警告图标
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)
            }

            VStack(spacing: 8) {
                Text("⚠️ 危险警告 ⚠️")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)

                Text(identification.riskAssessment.systemWarning)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // 滑动解锁
            SwipeToUnlockView {
                withAnimation {
                    isUnlocked = true
                }
                // 触发震动反馈
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }

            Spacer()
        }
    }

    // MARK: - 报告内容

    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 贴纸展示
                stickerSection

                // 物种信息
                speciesInfoSection

                // 风险评估
                riskAssessmentSection

                // 相似物种对比
                if let twins = primaryResult.toxicTwins, !twins.isEmpty {
                    toxicTwinsSection(twins)
                }

                // 操作按钮
                actionButtons
            }
            .padding()
        }
    }

    // MARK: - 贴纸展示区

    private var stickerSection: some View {
        ZStack {
            if isDangerous {
                Color.black
                    .cornerRadius(16)
            } else {
                Color.white
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }

            VStack(spacing: 12) {
                // 尝试加载贴纸图片
                if let image = ImageCacheService.shared.loadImage(from: identification.stickerUrl) {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .padding()

                        // 危险覆盖
                        if isDangerous {
                            dangerOverlay
                        }
                    }
                } else {
                    // 占位图
                    VStack(spacing: 12) {
                        Image(systemName: isDangerous ? "skull.fill" : "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(isDangerous ? .red : .green.opacity(0.5))

                        Text(primaryResult.commonName)
                            .font(.headline)
                            .foregroundStyle(isDangerous ? .red : .primary)
                    }
                    .frame(height: 180)
                }

                // 学名
                Text(primaryResult.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
        }
        .frame(height: 240)
    }

    private var dangerOverlay: some View {
        VStack {
            HStack {
                dangerTapeLabel
                Spacer()
            }
            Spacer()
        }
        .padding()
    }

    private var dangerTapeLabel: some View {
        Text("⚠️ DANGER ⚠️")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(.red)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.yellow.opacity(0.9))
            .rotationEffect(.degrees(-5))
    }

    // MARK: - 物种信息区

    private var speciesInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("物种信息")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                infoRow(label: "俗名", value: primaryResult.commonName)
                infoRow(label: "学名", value: primaryResult.scientificName)
                infoRow(label: "置信度", value: "\(Int(primaryResult.matchProbability * 100))%")
                infoRow(label: "稀有度", value: primaryResult.rarityLevel.displayName)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    // MARK: - 风险评估区

    private var riskAssessmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("风险评估")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(riskColor)
                            .frame(width: 12, height: 12)

                        Text(identification.riskAssessment.riskLevel.description)
                            .font(.headline)
                            .foregroundStyle(riskColor)
                    }

                    if !identification.riskAssessment.systemWarning.isEmpty {
                        Text(identification.riskAssessment.systemWarning)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // 风险等级图标
                Image(systemName: riskIcon)
                    .font(.title)
                    .foregroundStyle(riskColor)
            }
            .padding()
            .background(isDangerous ? Color.red.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDangerous ? Color.red : Color.clear, lineWidth: 2)
            )
        }
    }

    private var riskColor: Color {
        switch identification.riskAssessment.riskLevel {
        case .normal: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }

    private var riskIcon: String {
        switch identification.riskAssessment.riskLevel {
        case .normal: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }

    // MARK: - 相似物种区

    private func toxicTwinsSection(_ twins: [ToxicTwin]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("相似物种对比")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(twins) { twin in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                            .foregroundStyle(.orange)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(twin.twinName)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(twin.comparisonPoint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - 操作按钮

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onAddToHandbook()
                showSuccessMessage = true
            } label: {
                HStack {
                    Image(systemName: "book.badge.plus")
                    Text("加入手帐")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDangerous ? Color.red : Color.green)
                .cornerRadius(12)
            }

            Button {
                onDismiss()
            } label: {
                Text("关闭")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - 滑动解锁组件

struct SwipeToUnlockView: View {
    let onUnlock: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isUnlocked = false

    private let sliderWidth: CGFloat = 280
    private let knobSize: CGFloat = 50

    var body: some View {
        ZStack {
            // 背景轨道
            Capsule()
                .fill(Color.red.opacity(0.2))
                .frame(width: sliderWidth, height: knobSize)

            // 文字提示
            HStack {
                Spacer()
                Text("滑动解锁查看详情")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .opacity(1 - (offset / (sliderWidth - knobSize)))
                Spacer()
                    .frame(width: knobSize + 10)
            }
            .frame(width: sliderWidth, height: knobSize)

            // 滑块
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: knobSize, height: knobSize)

                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = value.translation.width
                            offset = max(0, min(newOffset, sliderWidth - knobSize))
                        }
                        .onEnded { value in
                            if offset > sliderWidth - knobSize - 20 {
                                // 解锁成功
                                withAnimation(.spring()) {
                                    offset = sliderWidth - knobSize
                                }
                                onUnlock()
                            } else {
                                // 弹回
                                withAnimation(.spring()) {
                                    offset = 0
                                }
                            }
                        }
                )

                Spacer()
            }
            .frame(width: sliderWidth, height: knobSize)
        }
    }
}

#Preview {
    IdentificationReportView(
        identification: MockDataService.shared.loadNormalIdentification()!,
        onAddToHandbook: {},
        onDismiss: {}
    )
}
