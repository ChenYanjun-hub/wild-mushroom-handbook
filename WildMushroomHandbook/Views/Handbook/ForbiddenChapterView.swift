//
//  ForbiddenChapterView.swift
//  WildMushroomHandbook
//
//  禁忌之地章节视图 - 展示危险物种
//

import SwiftUI

struct ForbiddenChapterView: View {
    @EnvironmentObject var handbookStorage: HandbookStorageService

    private var entries: [HandbookEntry] {
        handbookStorage.forbiddenEntries
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 警告横幅
            warningBanner

            if entries.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(entries) { entry in
                        NavigationLink(value: entry) {
                            ForbiddenEntryCard(entry: entry)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private var warningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text("禁忌档案")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text("以下物种具有致命毒性，请谨慎查看")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green.opacity(0.5))

            Text("太棒了！")
                .font(.title2)
                .fontWeight(.medium)

            Text("你还没有收录任何危险物种")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
        .padding()
    }
}

#Preview {
    ForbiddenChapterView()
        .environmentObject(HandbookStorageService.shared)
}
