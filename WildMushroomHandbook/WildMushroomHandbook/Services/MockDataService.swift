//
//  MockDataService.swift
//  WildMushroomHandbook
//
//  Mock 数据服务 - 提供模拟的识别结果数据
//

import Foundation

/// Mock 数据服务 - 单例模式
class MockDataService {
    static let shared = MockDataService()

    private init() {}

    // MARK: - 加载单个识别结果

    /// 加载普通级别的识别结果
    func loadNormalIdentification() -> MushroomIdentification? {
        return loadIdentification(from: "mock_identification_normal")
    }

    /// 加载危险级别的识别结果
    func loadCriticalIdentification() -> MushroomIdentification? {
        return loadIdentification(from: "mock_identification_critical")
    }

    /// 加载警告级别的识别结果
    func loadWarningIdentification() -> MushroomIdentification? {
        return loadIdentification(from: "mock_identification_warning")
    }

    /// 从 JSON 文件加载识别结果
    private func loadIdentification(from filename: String) -> MushroomIdentification? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load \(filename).json")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MushroomIdentification.self, from: data)
        } catch {
            print("Failed to decode \(filename).json: \(error)")
            return nil
        }
    }

    // MARK: - 加载所有识别结果

    /// 加载所有 Mock 识别结果
    func loadAllIdentifications() -> [MushroomIdentification] {
        guard let url = Bundle.main.url(forResource: "mock_identifications", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load mock_identifications.json")
            return []
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([MushroomIdentification].self, from: data)
        } catch {
            print("Failed to decode mock_identifications.json: \(error)")
            return []
        }
    }

    // MARK: - 模拟 API 调用

    /// 模拟识别 API 调用
    /// - Parameter type: 要返回的识别结果类型
    /// - Returns: 模拟的识别结果
    func simulateIdentification(type: MockIdentificationType = .random) -> MushroomIdentification? {
        switch type {
        case .normal:
            return loadNormalIdentification()
        case .warning:
            return loadWarningIdentification()
        case .critical:
            return loadCriticalIdentification()
        case .random:
            let types: [MockIdentificationType] = [.normal, .warning, .critical]
            let randomType = types.randomElement()!
            return simulateIdentification(type: randomType)
        }
    }
}

/// Mock 识别类型
enum MockIdentificationType {
    case normal
    case warning
    case critical
    case random
}
