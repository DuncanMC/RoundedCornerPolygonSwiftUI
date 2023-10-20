//
//  RoundedCornerPolygonSwiftUIApp.swift
//  RoundedCornerPolygonSwiftUI
//
//  Created by Duncan Champney on 10/20/23.
//

import SwiftUI

@main
struct RoundedCornerPolygonSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(cornerRadius: 30,
                        controlPoints: roundedRectCorners(
                          rect: CGRect(x: 100, y: 100, width: 200, height: 200),
                          byRoundingCorners: .allCorners,
                          cornerRadius: 30))
        }
    }
}
