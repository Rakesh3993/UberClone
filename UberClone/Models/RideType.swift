//
//  RideType.swift
//  UberClone
//
//  Created by Rakesh Kumar on 08/12/24.
//

import Foundation

enum RideType: Int, CaseIterable, Identifiable {
    case uberX
    case black
    case uberXL
    
    var id: Int { return rawValue }
    
    var description: String {
        switch self {
        case .uberX: return "UberX"
        case .black: return "UberBlack"
        case .uberXL: return "UberXL"
        }
    }
    
    var imageName: String {
        switch self {
        case .uberX: return "uber-x"
        case .black: return "uber-black"
        case .uberXL: return "uber-x"
        }
    }
    
    var baseFare: Double {
        switch self {
        case .uberX: return 50
        case .black: return 150
        case .uberXL: return 100
        }
    }
    
    func computePrices(for distanceInMeters: Double) -> Double {
        let distanceInMiles = distanceInMeters / 1600
        
        switch self {
        case .uberX: return distanceInMiles * 15 + baseFare
        case .black: return distanceInMiles * 30 + baseFare
        case .uberXL: return distanceInMiles * 25 + baseFare
        }
        
    }
}
