# 野生菌数字手帐与防御性鉴别 App (iOS MVP)

## 项目概述

这是一个以"防御性安全预警"为底线的野生菌电子手帐与生物收集系统。

- **视觉隐喻**：野生菌探险手帐
- **核心资产风格**：精致白边贴纸（Sticker Art）
- **开发框架**：SwiftUI + iOS 17+

## 项目结构

```
WildMushroomHandbook/
├── WildMushroomHandbookApp.swift      # App 入口
├── ContentView.swift                  # 主视图（Tab 导航）
├── Models/                            # 数据模型
│   ├── RiskLevel.swift               # 风险等级枚举
│   ├── ToxicTwin.swift               # 相似物种模型
│   ├── IdentificationResult.swift    # 识别结果模型
│   ├── RiskAssessment.swift          # 风险评估模型
│   ├── ProcessingResults.swift       # 图像处理结果
│   ├── ActionState.swift             # 行为状态模型
│   ├── HandbookMetadata.swift        # 手帐元数据
│   ├── MushroomIdentification.swift  # 完整识别响应
│   └── HandbookEntry.swift           # 手帐记录模型
├── Services/                          # 服务层
│   ├── MockDataService.swift         # Mock 数据服务
│   ├── HandbookStorageService.swift  # 手帐存储服务
│   └── ImageCacheService.swift       # 图片缓存服务
├── Views/
│   ├── Components/
│   │   └── HandbookEntryCard.swift   # 手帐卡片组件
│   ├── Handbook/
│   │   ├── HandbookMainView.swift    # 手帐主页
│   │   ├── CollectionChapterView.swift # 可食用菌图谱
│   │   ├── ForbiddenChapterView.swift  # 禁忌之地
│   │   └── HandbookEntryDetailView.swift # 记录详情页
│   ├── Camera/
│   │   └── CameraView.swift          # 相机拍摄视图
│   ├── Report/
│   │   └── IdentificationReportView.swift # 识别报告视图
│   └── ProfileView.swift             # 个人中心
└── Resources/
    └── MockData/                      # Mock 数据文件
        ├── mock_identification_normal.json
        ├── mock_identification_warning.json
        ├── mock_identification_critical.json
        └── mock_identifications.json
```

## 如何使用

### 方法一：在 Xcode 中创建新项目

1. 打开 Xcode，选择 **File > New > Project**
2. 选择 **iOS > App**
3. 产品名称填写 `WildMushroomHandbook`
4. 界面选择 **SwiftUI**，语言选择 **Swift**
5. 选择保存位置后，将本项目中的所有文件复制到对应目录

### 方法二：直接拖拽文件

如果你已有一个 Xcode 项目，可以直接将 `WildMushroomHandbook` 文件夹拖入项目中。

## 核心功能模块

### M1: 相机拍摄
- 拍摄野生菌照片
- 预处理状态动画
- Mock 识别结果返回

### M2: 防御性报告
- 贴纸化图像展示
- 风险等级可视化
- CRITICAL 级别滑动解锁
- 相似物种对比

### M3: 电子手帐
- 可食用菌图谱章节
- 禁忌之地章节
- 收录记录详情页
- 本地数据持久化

## Mock 数据说明

目前提供三种风险等级的 Mock 数据：

| 类型 | 文件 | 说明 |
|------|------|------|
| NORMAL | mock_identification_normal.json | 美味牛肝菌 |
| WARNING | mock_identification_warning.json | 毒蝇伞 |
| CRITICAL | mock_identification_critical.json | 白毒伞 |

## 开发进度

**当前阶段**：MVP 开发中
**最后更新**：2026-04-25

### 已完成
- ✅ 数据模型层（9个文件）
- ✅ 服务层（3个文件）
- ✅ 视图层（12个文件）
- ✅ Mock 数据（4个 JSON 文件）
- ✅ 引导页（3个版本迭代）

### 待开发
- [ ] 接入真实相机 API
- [ ] 接入后端识别 API
- [ ] 添加贴纸图片资源
- [ ] 完善动画效果
- [ ] 添加地图定位功能
- [ ] 实现真实的图像抠图功能
- [ ] 引导页设计优化

## 开发日志

详见 `开发日志/` 目录：
- [2026-04-25 开发日志](开发日志/2026-04-25.md)

## 技术栈

- SwiftUI
- Combine
- UserDefaults（数据持久化）
- NSCache（图片缓存）

---

**版本**: 1.0.0 (MVP)
**创建日期**: 2026-04-25
