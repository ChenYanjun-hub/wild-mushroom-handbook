//
//  MushroomIdentification.swift
//  WildMushroomHandbook
//
//  完整的野生菌识别响应模型
//

import Foundation

/// 完整的野生菌识别响应
struct MushroomIdentification: Codable, Identifiable {
    var id: String { requestId }

    /// 请求ID
    let requestId: String
    /// 图像处理结果
    let processingResults: ProcessingResults
    /// 行为状态
    let actionState: ActionState
    /// 风险评估
    let riskAssessment: RiskAssessment
    /// 识别结果列表
    let identificationResults: [IdentificationResult]
    /// 手帐元数据
    let handbookMetadata: HandbookMetadata

    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case processingResults = "processing_results"
        case actionState = "action_state"
        case riskAssessment = "risk_assessment"
        case identificationResults = "identification_results"
        case handbookMetadata = "handbook_metadata"
    }
}

// MARK: - 便捷访问属性
extension MushroomIdentification {
    /// 主要识别结果（置信度最高的）
    var primaryResult: IdentificationResult? {
        identificationResults.first
    }

    /// 是否为危险物种
    var isDangerous: Bool {
        riskAssessment.riskLevel.requiresDangerHandling
    }

    /// 贴纸图片URL
    var stickerUrl: String {
        processingResults.stickerAssetUrl
    }
}
