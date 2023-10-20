//
//  PolygonShape.swift
//  RoundedCornerPolygonSwiftUI
//
//  Created by Duncan Champney on 10/20/23.
//

import SwiftUI

struct PolygonShape: View {
  
  var defaultCornerRadius: CGFloat
  var controlPoints: [PolygonPoint]
  
  var animatableData: [PolygonPoint] {
    get { controlPoints}
    set { controlPoints = newValue}
  }

  var body: some View {
    Path(buildPolygonPathFrom(points: controlPoints, defaultCornerRadius: defaultCornerRadius))
      .stroke()
  }
}

#Preview {
  PolygonShape(defaultCornerRadius: 30,
               controlPoints: roundedRectCorners(
                rect: CGRect(x: 100, y: 100, width: 200, height: 200),
                byRoundingCorners: .allCorners,
                cornerRadius: 30))
}
