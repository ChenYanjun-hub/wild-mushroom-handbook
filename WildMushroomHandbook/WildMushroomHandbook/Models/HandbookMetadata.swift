//
//  HandbookMetadata.swift
//  WildMushroomHandbook
//
//  手帐元数据模型
//

import Foundation

/// 手帐元数据 - 记录采集信息
struct HandbookMetadata: Codable {
    /// 采集时间
    let collectionTimestamp: String
    /// 海拔高度
    let locationAltitude: String
    /// 采集地区
    let region: String

    enum CodingKeys: String, CodingKey {
        case collectionTimestamp = "collection_timestamp"
        case locationAltitude = "location_altitude"
        case region
    }
}
