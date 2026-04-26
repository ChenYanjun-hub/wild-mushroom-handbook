//
//  HandbookStorageService.swift
//  WildMushroomHandbook
//
//  手帐存储服务 - 管理本地手帐记录的持久化
//

import Foundation

/// 手帐存储服务 - 单例模式
class HandbookStorageService: ObservableObject {
    static let shared = HandbookStorageService()

    private let storageKey = "handbook_entries"

    /// 当前所有手帐记录
    @Published private(set) var entries: [HandbookEntry] = []

    private init() {
        loadEntries()
    }

    // MARK: - CRUD 操作

    /// 添加新的手帐记录
    func addEntry(_ entry: HandbookEntry) {
        entries.append(entry)
        saveEntries()
    }

    /// 从识别结果创建并添加手帐记录
    @discardableResult
    func addEntry(from identification: MushroomIdentification) -> HandbookEntry {
        let entry = HandbookEntry.from(identification: identification)
        addEntry(entry)
        return entry
    }

    /// 删除手帐记录
    func deleteEntry(_ entry: HandbookEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    /// 更新手帐记录
    func updateEntry(_ entry: HandbookEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }

    /// 标记禁忌记录为已查看
    func markAsViewed(_ entry: HandbookEntry) {
        var updatedEntry = entry
        updatedEntry.hasBeenViewed = true
        updateEntry(updatedEntry)
    }

    // MARK: - 查询方法

    /// 获取普通收藏记录
    var normalEntries: [HandbookEntry] {
        entries.filter { $0.riskLevel != .critical }
    }

    /// 获取禁忌记录
    var forbiddenEntries: [HandbookEntry] {
        entries.filter { $0.riskLevel == .critical }
    }

    /// 按物种 ID 查找记录
    func findEntry(bySpeciesId speciesId: String) -> HandbookEntry? {
        entries.first { $0.speciesId == speciesId }
    }

    /// 按记录 ID 查找
    func findEntry(byId id: UUID) -> HandbookEntry? {
        entries.first { $0.id == id }
    }

    /// 统计信息
    var totalCount: Int { entries.count }
    var normalCount: Int { normalEntries.count }
    var forbiddenCount: Int { forbiddenEntries.count }
    var uniqueSpeciesCount: Int { Set(entries.map { $0.speciesId }).count }

    // MARK: - 持久化

    /// 保存到本地存储
    private func saveEntries() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(entries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }

    /// 从本地存储加载
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            entries = []
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            entries = try decoder.decode([HandbookEntry].self, from: data)
        } catch {
            print("Failed to load entries: \(error)")
            entries = []
        }
    }

    /// 清空所有记录（用于测试）
    func clearAll() {
        entries = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - 预加载 Mock 数据（开发调试用）

    /// 预加载 Mock 数据到手帐
    func preloadMockData() {
        let mockIdentifications = MockDataService.shared.loadAllIdentifications()
        for identification in mockIdentifications {
            // 避免重复添加
            if !entries.contains(where: { $0.identificationId == identification.requestId }) {
                addEntry(from: identification)
            }
        }
    }
}
