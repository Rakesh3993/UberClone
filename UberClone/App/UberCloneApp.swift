//
//  UberCloneApp.swift
//  UberClone
//
//  Created by Rakesh Kumar on 06/12/24.
//

import SwiftUI

@main
struct UberCloneApp: App {
    @StateObject var locationSearchViewModel = LocationSearchViewModel()
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationSearchViewModel)
        }
    }
}
