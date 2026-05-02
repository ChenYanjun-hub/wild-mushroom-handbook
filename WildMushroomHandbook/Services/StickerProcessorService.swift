//
//  StickerProcessorService.swift
//  WildMushroomHandbook
//
//  贴纸处理服务 - 本地抠图 + 白边贴纸效果
//

import UIKit
import Vision
import CoreImage

/// 贴纸处理服务 - 单例模式
class StickerProcessorService {
    static let shared = StickerProcessorService()

    private let context = CIContext()

    // MARK: - 公开方法

    /// 处理图片：抠图 + 白边 + 投影
    /// - Parameter image: 原始图片
    /// - Returns: 贴纸图片
    func processToSticker(_ image: UIImage) async -> UIImage? {
        // 1. 移除背景
        guard let removedBackground = await removeBackground(from: image) else {
            // 如果抠图失败，使用原图添加白边
            return addWhiteBorder(to: image, withBackground: false)
        }

        // 2. 添加白边和投影
        let sticker = addWhiteBorder(to: removedBackground, withBackground: true)

        return sticker
    }

    // MARK: - 背景移除

    /// 使用 Vision 框架移除背景
    @available(iOS 15.0, *)
    private func removeBackground(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 创建 Vision 请求
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            // 执行请求
            try handler.perform([request])

            // 获取遮罩
            guard let result = request.results?.first else {
                return nil
            }

            // 应用遮罩移除背景
            return await applyMask(result, to: cgImage)

        } catch {
            print("背景移除失败: \(error)")
            return nil
        }
    }

    /// 应用遮罩移除背景
    @available(iOS 15.0, *)
    private func applyMask(_ mask: VNInstanceMaskObservation, to cgImage: CGImage) async -> UIImage? {
        let width = cgImage.width
        let height = cgImage.height

        // 创建原图 CIImage
        let originalImage = CIImage(cgImage: cgImage)

        // 生成遮罩图像
        guard let maskedImage = try? mask.generateMaskedImage(
            ofInstances: mask.allInstances,
            from: originalImage,
            croppedToInstancesExtent: false
        ) else {
            return nil
        }

        // 渲染输出
        guard let outputCGImage = context.createCGImage(maskedImage, from: maskedImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - 白边贴纸效果

    /// 添加白边和投影效果
    private func addWhiteBorder(to image: UIImage, withBackground: Bool) -> UIImage {
        let borderWidth: CGFloat = 12  // 白边宽度
        let cornerRadius: CGFloat = 16 // 圆角半径
        let shadowRadius: CGFloat = 8  // 投影半径
        let shadowOffset = CGSize(width: 0, height: 4)
        let shadowOpacity: CGFloat = 0.15

        let originalSize = image.size

        // 计算带白边的总尺寸
        let totalSize = CGSize(
            width: originalSize.width + borderWidth * 2,
            height: originalSize.height + borderWidth * 2
        )

        // 创建绘图上下文
        UIGraphicsBeginImageContextWithOptions(totalSize, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }

        // 设置投影
        context.setShadow(
            offset: shadowOffset,
            blur: shadowRadius,
            color: UIColor.black.withAlphaComponent(shadowOpacity).cgColor
        )

        if withBackground {
            // 绘制白色圆角背景
            let backgroundRect = CGRect(origin: .zero, size: totalSize)
            let path = UIBezierPath(
                roundedRect: backgroundRect,
                cornerRadius: cornerRadius
            )

            UIColor.white.setFill()
            path.fill()
        }

        // 重置投影（原图不需要投影）
        context.setShadow(offset: .zero, blur: 0, color: nil)

        // 绘制原图
        let imageRect = CGRect(
            x: borderWidth,
            y: borderWidth,
            width: originalSize.width,
            height: originalSize.height
        )
        image.draw(in: imageRect)

        // 获取结果图片
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    // MARK: - 降级方案

    /// 简单的边缘检测抠图（备用方案）
    private func simpleEdgeCutout(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        // 使用 Core Image 的边缘检测
        let edgeFilter = CIFilter(name: "CIEdges")
        edgeFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        edgeFilter?.setValue(3.0, forKey: kCIInputIntensityKey)

        guard let edgeOutput = edgeFilter?.outputImage else { return nil }

        // 转换回 UIImage
        guard let cgImage = context.createCGImage(edgeOutput, from: edgeOutput.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
