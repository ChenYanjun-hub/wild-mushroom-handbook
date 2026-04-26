//
//  HandbookMainView.swift
//  WildMushroomHandbook
//
//  手帐主视图 - 展示所有收录的菌子
//

import SwiftUI

struct HandbookMainView: View {
    @EnvironmentObject var handbookStorage: HandbookStorageService
    @State private var selectedChapter: HandbookChapter = .collection

    var body: some View {
        NavigationStack {
            ZStack {
                // 纸张质感背景
                Color(red: 0.98, green: 0.96, blue: 0.93)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 章节选择器
                    chapterPicker

                    // 内容区域
                    ScrollView {
                        switch selectedChapter {
                        case .collection:
                            CollectionChapterView()
                        case .forbidden:
                            ForbiddenChapterView()
                        }
                    }
                }
            }
            .navigationTitle("野生菌手帐")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // 预加载 Mock 数据
                        handbookStorage.preloadMockData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    // MARK: - 章节选择器

    private var chapterPicker: some View {
        HStack(spacing: 0) {
            ChapterTab(
                title: "可食用菌图谱",
                count: handbookStorage.normalCount,
                isSelected: selectedChapter == .collection
            ) {
                selectedChapter = .collection
            }

            ChapterTab(
                title: "禁忌之地",
                count: handbookStorage.forbiddenCount,
                isSelected: selectedChapter == .forbidden,
                isDanger: true
            ) {
                selectedChapter = .forbidden
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - 章节枚举

enum HandbookChapter {
    case collection  // 可食用菌图谱
    case forbidden   // 禁忌之地
}

// MARK: - 章节标签组件

struct ChapterTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    var isDanger: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(isSelected ? .bold : .regular)

                    Text("(\(count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 选中指示器
                Rectangle()
                    .fill(isSelected ? (isDanger ? Color.red : Color.green) : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .foregroundStyle(isDanger ? (isSelected ? .red : .secondary) : (isSelected ? .green : .secondary))
    }
}

#Preview {
    HandbookMainView()
        .environmentObject(HandbookStorageService.shared)
}
