//
//  ContentView.swift
//  RoundedCornerPolygonSwiftUI
//
//  Created by Duncan Champney on 10/20/23.
//

import SwiftUI

struct ContentView: View {
  @State var cornerRadius: CGFloat = 30
  @State var controlPoints: [PolygonPoint]
  var body: some View {
    VStack {
      PolygonShape(defaultCornerRadius: cornerRadius,
                   controlPoints: controlPoints)
      Spacer()
        .frame(width: 0, height: 20)
      VStack(alignment: .center) {
        ForEach(Array(controlPoints.enumerated()), id: \.element) { index, point in
          HStack(alignment: .center) {
            Spacer()
              .frame(width: 50)
            Toggle("Round corner \(index)", isOn: self.$controlPoints[index].isRounded)
            Spacer()
              .frame(width: 50)
          }
        }
      }
      Spacer()
        .frame(minHeight: 50)
    }
  }
}

#Preview {
  ContentView(cornerRadius: 30,
              controlPoints: roundedRectCorners(
                rect: CGRect(x: 100, y: 100, width: 200, height: 200),
                byRoundingCorners: .allCorners,
                cornerRadius: 30))
}
