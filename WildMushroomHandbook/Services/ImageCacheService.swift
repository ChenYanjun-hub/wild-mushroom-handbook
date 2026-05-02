//
//  ImageCacheService.swift
//  WildMushroomHandbook
//
//  图片缓存服务 - 管理贴纸图片的本地缓存
//

import Foundation
import UIKit

/// 图片缓存服务 - 单例模式
class ImageCacheService {
    static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("StickerCache")
    }

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB

        // 确保缓存目录存在
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - 获取图片

    /// 获取贴纸图片（优先从缓存获取）
    func getStickerImage(named name: String) -> UIImage? {
        let key = name as NSString

        // 1. 内存缓存
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        // 2. 磁盘缓存
        let fileURL = cacheDirectory.appendingPathComponent(name)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key, cost: data.count)
            return image
        }

        // 3. Bundle 资源（Mock 图片）
        if let image = UIImage(named: name) {
            cache.setObject(image, forKey: key)
            return image
        }

        return nil
    }

    // MARK: - 保存图片

    /// 保存图片到缓存
    func saveStickerImage(_ image: UIImage, named name: String) {
        let key = name as NSString
        cache.setObject(image, forKey: key)

        // 同时保存到磁盘
        let fileURL = cacheDirectory.appendingPathComponent(name)
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }

    /// 从本地路径加载图片
    func loadImage(from path: String) -> UIImage? {
        if path.hasPrefix("mock_images/") {
            // Mock 图片，从 Bundle 加载
            let imageName = path.replacingOccurrences(of: "mock_images/", with: "")
            return getStickerImage(named: imageName)
        } else if path.hasPrefix("/") {
            // 绝对路径
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return UIImage(data: data)
            }
        }
        return nil
    }

    // MARK: - 清理缓存

    /// 清空内存缓存
    func clearMemoryCache() {
        cache.removeAllObjects()
    }

    /// 清空磁盘缓存
    func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// 清空所有缓存
    func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }
}
