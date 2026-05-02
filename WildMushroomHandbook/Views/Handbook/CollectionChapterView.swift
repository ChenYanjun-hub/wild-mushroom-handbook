//
//  CollectionChapterView.swift
//  WildMushroomHandbook
//
//  可食用菌图谱章节视图
//

import SwiftUI

struct CollectionChapterView: View {
    @EnvironmentObject var handbookStorage: HandbookStorageService

    private var entries: [HandbookEntry] {
        handbookStorage.normalEntries
    }

    var body: some View {
        if entries.isEmpty {
            emptyStateView
        } else {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        HandbookEntryCard(entry: entry)
                    }
                }
            }
            .padding()
            .navigationDestination(for: HandbookEntry.self) { entry in
                HandbookEntryDetailView(entry: entry)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green.opacity(0.3))

            Text("手帐还是空的")
                .font(.title2)
                .fontWeight(.medium)

            Text("拍摄野生菌照片开始你的采集之旅")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 400)
    }
}

#Preview {
    CollectionChapterView()
        .environmentObject(HandbookStorageService.shared)
}
