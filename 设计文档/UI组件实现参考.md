# UI组件实现参考：野生菌数字手帐

> Swift UI / CSS 双语实现参考

---

## 1. 色彩定义

### Swift UI Color Extension

```swift
// 文件: Colors.swift

import SwiftUI

extension Color {
    // MARK: - 安全态色板
    struct Safe {
        static let primary = Color(hex: "9B7ED9")
        static let light = Color(hex: "C8B8E8")
        static let background = Color(hex: "E8DFF5")

        static let forestGreen = Color(hex: "4A7C59")
        static let warmBrown = Color(hex: "8B7355")
        static let cream = Color(hex: "F5F0E8")
    }

    // MARK: - 警示态色板
    struct Danger {
        static let red = Color(hex: "E53935")
        static let orange = Color(hex: "FF6D00")
        static let yellow = Color(hex: "FFEA00")
        static let darkRed = Color(hex: "4A0E0E")
    }

    // MARK: - 中性色
    struct Neutral {
        static let dark = Color(hex: "2D2D2D")
        static let medium = Color(hex: "666666")
        static let light = Color(hex: "E5E5E5")
        static let white = Color(hex: "FFFFFF")
    }
}

// Color Extension for Hex
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
            (a, r, g, b) = (1, 1, 1, 0)
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
```

### CSS 变量定义

```css
/* 文件: variables.css */

:root {
  /* 安全态色板 */
  --color-safe-primary: #9B7ED9;
  --color-safe-light: #C8B8E8;
  --color-safe-background: #E8DFF5;

  --color-safe-forest-green: #4A7C59;
  --color-safe-warm-brown: #8B7355;
  --color-safe-cream: #F5F0E8;

  /* 警示态色板 */
  --color-danger-red: #E53935;
  --color-danger-orange: #FF6D00;
  --color-danger-yellow: #FFEA00;
  --color-danger-dark-red: #4A0E0E;

  /* 中性色 */
  --color-neutral-dark: #2D2D2D;
  --color-neutral-medium: #666666;
  --color-neutral-light: #E5E5E5;
  --color-neutral-white: #FFFFFF;

  /* 渐变 */
  --gradient-safe-bg: linear-gradient(135deg, #E8DFF5 0%, #F5F0E8 50%, #C8B8E8 100%);
  --gradient-danger-bg: linear-gradient(180deg, #4A0E0E 0%, #8B0000 50%, #E53935 100%);

  /* 圆角 */
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 24px;
  --radius-full: 9999px;

  /* 阴影 */
  --shadow-card: 0 4px 16px rgba(0, 0, 0, 0.08);
  --shadow-sticker: 0 4px 8px rgba(0, 0, 0, 0.15);
  --shadow-danger: 0 0 30px rgba(229, 57, 53, 0.5);
}
```

---

## 2. 核心组件

### 2.1 贴纸组件 (Sticker View)

**Swift UI 实现：**

```swift
// 文件: StickerView.swift

import SwiftUI

struct StickerView: View {
    let imageName: String
    let isDanger: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            // 基础贴纸
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .background(Color.white)
                .cornerRadius(12)
                .padding(8) // 白边
                .background(Color.white)
                .cornerRadius(16)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4
                )

            // 危险覆盖层
            if isDanger {
                DangerOverlay()
                    .frame(width: size + 16, height: size + 16)
                    .cornerRadius(16)
            }
        }
    }
}

// DANGER 胶带覆盖层
struct DangerOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 斜纹背景
                DiagonalStripes()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.Danger.yellow.opacity(0.8),
                                Color.Danger.red.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // DANGER 文字
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("DANGER")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-15))
                            .padding(8)
                            .background(Color.Danger.red)
                            .cornerRadius(4)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

// 斜纹图案
struct DiagonalStripes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stripeWidth: CGFloat = 20
        let angle = 45.0

        for i in stride(from: -rect.height, to: rect.width + rect.height, by: stripeWidth * 2) {
            let x = i
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.height))
            path.addLine(to: CGPoint(x: x + rect.height + stripeWidth, y: rect.height))
            path.addLine(to: CGPoint(x: x + stripeWidth, y: 0))
        }

        return path
    }
}

// 使用示例
#Preview {
    HStack {
        StickerView(imageName: "boletus", isDanger: false, size: 150)
        StickerView(imageName: "amanita", isDanger: true, size: 150)
    }
    .padding()
    .background(Color.Safe.cream)
}
```

**CSS 实现：**

```html
<!-- 文件: sticker.html -->

<div class="sticker-container">
  <!-- 安全态贴纸 -->
  <div class="sticker sticker--safe">
    <img src="boletus.png" alt="牛肝菌" />
  </div>

  <!-- 危险态贴纸 -->
  <div class="sticker sticker--danger">
    <img src="amanita.png" alt="白毒伞" />
    <div class="sticker__danger-overlay">
      <span class="danger-tape">DANGER</span>
    </div>
  </div>
</div>

<style>
.sticker-container {
  display: flex;
  gap: 24px;
  padding: 24px;
  background: var(--color-safe-cream);
}

.sticker {
  position: relative;
  width: 150px;
  height: 150px;
  background: white;
  border-radius: var(--radius-lg);
  padding: 8px;
  box-shadow: var(--shadow-sticker);
  transition: transform 0.3s ease;
}

.sticker:hover {
  transform: rotate(-2deg) scale(1.02);
}

.sticker img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: var(--radius-md);
}

/* 危险态样式 */
.sticker--danger {
  border: 2px solid var(--color-danger-red);
}

.sticker__danger-overlay {
  position: absolute;
  inset: 0;
  background:
    repeating-linear-gradient(
      45deg,
      transparent,
      transparent 10px,
      rgba(255, 234, 0, 0.7) 10px,
      rgba(255, 234, 0, 0.7) 20px
    ),
    repeating-linear-gradient(
      -45deg,
      transparent,
      transparent 10px,
      rgba(229, 57, 53, 0.5) 10px,
      rgba(229, 57, 53, 0.5) 20px
    );
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
}

.danger-tape {
  background: var(--color-danger-red);
  color: white;
  font-weight: 900;
  font-family: monospace;
  font-size: 14px;
  padding: 8px 16px;
  border-radius: 4px;
  transform: rotate(-15deg);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}
</style>
```

---

### 2.2 结果卡片组件 (Result Card)

**Swift UI 实现：**

```swift
// 文件: ResultCardView.swift

import SwiftUI

struct ResultCardView: View {
    let data: IdentificationResult

    var body: some View {
        VStack(spacing: 0) {
            // 状态栏
            StatusBar(isDanger: data.riskLevel == .critical)

            // 主要内容
            ScrollView {
                VStack(spacing: 24) {
                    // 贴纸展示区
                    StickerView(
                        imageName: data.stickerAssetUrl,
                        isDanger: data.riskLevel == .critical,
                        size: 200
                    )
                    .padding(.top, 20)

                    // 名称信息
                    VStack(spacing: 8) {
                        Text(data.commonName)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(data.riskLevel == .critical ? .white : .Neutral.dark)

                        Text(data.scientificName)
                            .font(.system(size: 16, weight: .regular))
                            .italic()
                            .foregroundColor(data.riskLevel == .critical ? .white.opacity(0.8) : .Neutral.medium)
                    }

                    Divider()
                        .background(data.riskLevel == .critical ? Color.white.opacity(0.3) : Color.Neutral.light)

                    // 状态标签
                    StatusBadge(riskLevel: data.riskLevel, matchProbability: data.matchProbability)

                    // 详细信息
                    DetailInfoView(data: data)

                    Spacer()
                }
                .padding()
            }

            // 底部操作栏
            ActionBar(
                isDanger: data.riskLevel == .critical,
                onCollect: { /* 收藏逻辑 */ },
                onShare: { /* 分享逻辑 */ }
            )
        }
        .background(
            data.riskLevel == .critical
                ? AnyView(DangerBackground())
                : AnyView(SafeBackground())
        )
    }
}

// 安全态背景
struct SafeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.Safe.background,
                Color.Safe.cream,
                Color.Safe.light
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// 危险态背景
struct DangerBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.Danger.darkRed,
                Color(hex: "8B0000"),
                Color.Danger.red.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// 状态标签
struct StatusBadge: View {
    let riskLevel: RiskLevel
    let matchProbability: Double

    var body: some View {
        HStack(spacing: 16) {
            // 风险状态
            HStack(spacing: 6) {
                Image(systemName: riskLevel.icon)
                Text(riskLevel.statusText)
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(riskLevel == .critical ? .white : .Safe.forestGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                riskLevel == .critical
                    ? Color.Danger.red.opacity(0.3)
                    : Color.Safe.forestGreen.opacity(0.1)
            )
            .cornerRadius(20)

            // 匹配度
            Text("匹配度 \(Int(matchProbability * 100))%")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.Neutral.medium)
        }
    }
}

// 详细信息视图
struct DetailInfoView: View {
    let data: IdentificationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(icon: "location.fill", label: "位置", value: data.location)
            InfoRow(icon: "mountain.2.fill", label: "海拔", value: "\(data.altitude)m")
            InfoRow(icon: "clock.fill", label: "时间", value: data.timestamp)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.Safe.primary)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.Neutral.medium)
                .frame(width: 40, alignment: .leading)

            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.Neutral.dark)

            Spacer()
        }
    }
}

// 底部操作栏
struct ActionBar: View {
    let isDanger: Bool
    let onCollect: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onCollect) {
                HStack {
                    Image(systemName: "book.fill")
                    Text("收录到手帐")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isDanger
                        ? Color.Danger.red
                        : Color.Safe.primary
                )
                .cornerRadius(12)
            }

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isDanger ? .white : .Safe.primary)
                    .frame(width: 56, height: 56)
                    .background(
                        isDanger
                            ? Color.white.opacity(0.2)
                            : Color.Safe.primary.opacity(0.1)
                    )
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// Risk Level 枚举
enum RiskLevel {
    case safe
    case low
    case critical

    var icon: String {
        switch self {
        case .safe, .low: return "checkmark.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }

    var statusText: String {
        switch self {
        case .safe: return "可食用"
        case .low: return "低风险"
        case .critical: return "致命剧毒"
        }
    }
}

// 数据模型
struct IdentificationResult {
    let commonName: String
    let scientificName: String
    let stickerAssetUrl: String
    let riskLevel: RiskLevel
    let matchProbability: Double
    let location: String
    let altitude: Int
    let timestamp: String
}
```

---

### 2.3 滑动解锁组件 (Slide to Unlock)

**Swift UI 实现：**

```swift
// 文件: SlideToUnlockView.swift

import SwiftUI

struct SlideToUnlockView: View {
    @State private var offset: CGFloat = 0
    @State private var isUnlocked = false
    let onUnlock: () -> Void

    private let sliderWidth: CGFloat = 60

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景轨道
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 60)

                // 进度指示
                Capsule()
                    .fill(Color.Danger.red)
                    .frame(width: offset + sliderWidth, height: 60)

                // 提示文字
                HStack {
                    Spacer()
                    Text("滑动以解锁查看详情")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .opacity(1 - (offset / (geometry.size.width - sliderWidth)))

                // 滑块
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.Danger.red)
                            .frame(width: sliderWidth - 8, height: sliderWidth - 8)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.interactiveSpring()) {
                                    offset = min(
                                        max(0, value.translation.width),
                                        geometry.size.width - sliderWidth
                                    )
                                }
                            }
                            .onEnded { value in
                                let threshold = geometry.size.width * 0.8
                                if offset > threshold {
                                    withAnimation(.spring()) {
                                        offset = geometry.size.width - sliderWidth
                                        isUnlocked = true
                                    }
                                    onUnlock()
                                } else {
                                    withAnimation(.spring()) {
                                        offset = 0
                                    }
                                }
                            }
                    )

                    Spacer()
                }
                .padding(4)
            }
        }
        .frame(height: 60)
    }
}

// 使用示例
#Preview {
    ZStack {
        Color.Danger.darkRed.ignoresSafeArea()

        VStack {
            Spacer()
            SlideToUnlockView {
                print("Unlocked!")
            }
            .padding()
        }
    }
}
```

---

### 2.4 手帐网格视图 (Handbook Grid)

**Swift UI 实现：**

```swift
// 文件: HandbookGridView.swift

import SwiftUI

struct HandbookGridView: View {
    @State private var selectedTab = 0
    let stickers: [StickerItem]

    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.Safe.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 标题区域
                    HeaderSection()

                    // Tab 切换
                    TabSelector(selectedTab: $selectedTab)

                    // 贴纸网格
                    StickerGrid(
                        stickers: selectedTab == 0
                            ? stickers.filter { !$0.isDanger }
                            : stickers.filter { $0.isDanger }
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("「我的野生菌手帐」")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(.Neutral.dark)

            HStack(spacing: 4) {
                Text("已收录")
                    .font(.system(size: 14))
                    .foregroundColor(.Neutral.medium)

                Text("42")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.Safe.primary)

                Text("种 · 探索")
                    .font(.system(size: 14))
                    .foregroundColor(.Neutral.medium)

                Text("7")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.Safe.primary)

                Text("地")
                    .font(.system(size: 14))
                    .foregroundColor(.Neutral.medium)
            }
        }
        .padding(.vertical, 20)
    }
}

struct TabSelector: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "可食用",
                count: 38,
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            TabButton(
                title: "禁忌",
                count: 4,
                isSelected: selectedTab == 1,
                isDanger: true
            ) {
                selectedTab = 1
            }
        }
        .padding(.horizontal)
    }
}

struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    var isDanger: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                Text("\(count)")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(
                isSelected
                    ? (isDanger ? .Danger.red : .Safe.primary)
                    : .Neutral.medium
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? (isDanger ? Color.Danger.red.opacity(0.1) : Color.Safe.primary.opacity(0.1))
                    : Color.clear
            )
            .cornerRadius(12)
        }
    }
}

struct StickerGrid: View {
    let stickers: [StickerItem]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(stickers) { sticker in
                    StickerCell(sticker: sticker)
                }
            }
            .padding()
        }
    }
}

struct StickerCell: View {
    let sticker: StickerItem

    var body: some View {
        VStack(spacing: 8) {
            StickerView(
                imageName: sticker.imageUrl,
                isDanger: sticker.isDanger,
                size: 120
            )

            Text(sticker.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(sticker.isDanger ? .Danger.red : .Neutral.dark)

            Text(sticker.date)
                .font(.system(size: 12))
                .foregroundColor(.Neutral.medium)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StickerItem: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let isDanger: Bool
    let date: String
}
```

---

## 3. 动画效果

### 3.1 收录动画 (Collect Animation)

```swift
// 文件: CollectAnimation.swift

struct CollectAnimationView: View {
    @State private var isCollecting = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    @State private var yOffset: CGFloat = 0

    let onComplete: () -> Void

    func collect() {
        // 阶段1: 放大旋转
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.2
            rotation = -5
        }

        // 阶段2: 缩小飞走
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.5)) {
                scale = 0.3
                rotation = 0
                opacity = 0
                yOffset = -200
            }
        }

        // 阶段3: 完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete()
        }
    }

    var body: some View {
        Image("sticker")
            .resizable()
            .frame(width: 150, height: 150)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(y: yOffset)
    }
}
```

### 3.2 危险脉动 (Danger Pulse)

```swift
// 文件: DangerPulse.swift

struct DangerPulseView: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(Color.Danger.red)
            .frame(width: 100, height: 100)
            .overlay(
                Circle()
                    .stroke(Color.Danger.yellow, lineWidth: 4)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
    }
}
```

### 3.3 CSS 动画

```css
/* 收录动画 */
@keyframes collect {
  0% {
    transform: scale(1) rotate(0deg);
  }
  30% {
    transform: scale(1.2) rotate(-5deg);
  }
  100% {
    transform: scale(0.3) rotate(0deg) translateY(-200px);
    opacity: 0;
  }
}

.sticker.collecting {
  animation: collect 0.8s ease-in-out forwards;
}

/* 危险脉动 */
@keyframes danger-pulse {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(229, 57, 53, 0.7);
  }
  50% {
    box-shadow: 0 0 0 20px rgba(229, 57, 53, 0);
  }
}

.sticker--danger {
  animation: danger-pulse 1.5s ease-in-out infinite;
}

/* 入场动画 */
@keyframes fade-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.card {
  animation: fade-up 0.4s ease-out;
}
```

---

## 4. 工具函数

### 4.1 触觉反馈

```swift
// 文件: HapticManager.swift

import UIKit

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
}

class HapticManager {
    static let shared = HapticManager()

    func trigger(_ type: HapticType) {
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()

        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)

        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

// 使用示例
HapticManager.shared.trigger(.success)  // 收录成功
HapticManager.shared.trigger(.heavy)    // 显示危险内容
```

### 4.2 纸张纹理生成

```swift
// 文件: PaperTexture.swift

import SwiftUI

struct PaperTexture: View {
    var body: some View {
        Color.Safe.cream
            .overlay(
                Canvas { context, size in
                    // 添加噪点纹理
                    for _ in 0..<1000 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let opacity = Double.random(in: 0.02...0.05)

                        context.fill(
                            Path(roundedRect: CGRect(x: x, y: y, width: 1, height: 1), cornerRadius: 0),
                            with: .color(.black.opacity(opacity))
                        )
                    }
                }
            )
    }
}
```

---

*文档版本: v1.0*
*最后更新: 2026.04.26*
