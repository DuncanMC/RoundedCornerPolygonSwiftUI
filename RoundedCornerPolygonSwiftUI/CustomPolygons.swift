//
//  CustomPolygons.swift
//
//  Created by Duncan Champney on 4/14/21.
//

import UIKit
import SwiftUI

/// A struct describing a single vertex in a polygon. Used in building polygon paths with a mixture of rounded an sharp-edged vertexes.
public struct PolygonPoint: Hashable, VectorArithmetic {
    var point: CGPoint
    var isRounded: Bool
    var customCornerRadius: CGFloat?
    
    init(point: CGPoint,
         isRounded: Bool,
         customCornerRadius: CGFloat? = nil) {
        self.point = point
        self.isRounded = isRounded
        self.customCornerRadius = customCornerRadius
    }
    init(previousPoint: PolygonPoint, isRounded: Bool) {
        self.init(point: previousPoint.point, isRounded: isRounded, customCornerRadius: previousPoint.customCornerRadius)
    }
    //MARK: VectorArithmetic
    public var magnitudeSquared: Double = 1
    
    public static var zero: PolygonPoint = .init(point: .zero, isRounded: false, customCornerRadius: .zero)
    
    public mutating func scale(by rhs: Double) {
        self = .init(point: point * rhs,
                     isRounded:
                        self.isRounded,
                     customCornerRadius:
                        self.customCornerRadius
        )
    }
    public static func + (lhs: PolygonPoint, rhs: PolygonPoint) -> PolygonPoint {
        
        .init(point: lhs.point + rhs.point,
              isRounded:
                lhs.isRounded && rhs.isRounded,
              customCornerRadius:
                // Which point's corner radius should it use?
                max(lhs.customCornerRadius ?? 0, rhs.customCornerRadius ?? 0)
        )
    }
    public static func - (lhs: PolygonPoint, rhs: PolygonPoint) -> PolygonPoint {
        
        .init(point: lhs.point - rhs.point,
              isRounded:
                lhs.isRounded || rhs.isRounded,
              customCornerRadius:
                max(lhs.customCornerRadius ?? 0, rhs.customCornerRadius ?? 0)
        )
    }
}

extension CGPoint: AdditiveArithmetic  {
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    public static func * (lhs: CGPoint, rhs: Double) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

/**
 Returns an array of PolygonPoint structs describing a rounded rectangle with a mixture of rounded and sharp corners, as specified by the options in `corners`

 - Parameter  rect: The starting rectangle who's corners you wish to round
 - Parameter corners: The corners to round
 - Parameter cornerRadius: The corner radius to use
 - Returns: An array of PolygonPoint structs describing the desired rounded-corner rectangle
 */
public func roundedRectCorners(rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadius: CGFloat) -> [PolygonPoint] {
    return [
        PolygonPoint(point: rect.origin, isRounded: corners.contains(.topLeft), customCornerRadius: cornerRadius),
        PolygonPoint(point: CGPoint(x: rect.maxX, y: rect.origin.y), isRounded: corners.contains(.topRight), customCornerRadius: cornerRadius),
        PolygonPoint(point: CGPoint(x: rect.maxX, y: rect.maxY), isRounded: corners.contains(.bottomRight), customCornerRadius: cornerRadius),
        PolygonPoint(point: CGPoint(x: rect.origin.x, y: rect.maxY), isRounded: corners.contains(.bottomLeft), customCornerRadius: cornerRadius),
    ]
}

/**
This function works like the UIBezierPath initializer `init(roundedRect:byRoundingCorners:cornerRadii:)` It returns a CGPath a rounded rectangle with a mixture of rounded and sharp corners, as specified by the options in `corners`.

 Unlike the UIBezierPath `init(roundedRect:byRoundingCorners:cornerRadii:` intitializer, The CGPath that is returned by this function will animate smoothly from rounded to non-rounded corners.

 - Parameter  rect: The starting rectangle who's corners you wish to round
 - Parameter corners: The corners to round
 - Parameter cornerRadius: The corner radius to use
 - Returns: A CGPath containing for the rounded rectangle.
*/
public func roundedRectPath(rect: CGRect, byRoundingCorners corners: UIRectCorner, cornerRadius: CGFloat) -> CGPath {
    let rectCorners = roundedRectCorners(rect: rect, byRoundingCorners:  corners, cornerRadius: cornerRadius)
    return buildPolygonPathFrom(points: rectCorners, defaultCornerRadius: cornerRadius)
}

/**
 A function to create and return a`CGPath` of a polygon from an array of `PolygonPoint`s. For each `PolygonPoint`, if its `isRounded` property is true, that point's vertex is rounded in the resulsting path.
 - Parameter points: The array of `PolygonPoint`s to use in buliding the polygon.
 - Parameter  defaultCornerRadius: a default corner radius to use for curved corners that do not specify a custom corner radius.
 */
public func buildPolygonPathFrom(points: [PolygonPoint], defaultCornerRadius: CGFloat) -> CGPath {
    guard points.count >= 3 else { return CGPath(rect: CGRect.zero, transform: nil) }
    let first = points.first!
    let last = points.last!

    let path = CGMutablePath()

    // Start at the midpoint between the first and last vertex in our polygon
    // (Since that will always be in the middle of a straight line segment.)
    let midpoint = CGPoint(x: (first.point.x + last.point.x) / 2, y: (first.point.y + last.point.y) / 2)
    path.move(to: midpoint)

    //Loop through the points in our polygon.
    for (index, point) in points.enumerated() {
        //Draw an arc from the previous vertex (the current point), around this vertex, and pointing to the next
        let nextIndex = (index+1) % points.count
        let nextPoint = points[nextIndex]
        var radius: CGFloat = 0 // For non-rounded points, use an arc radius of 0 (allows us to animate between rounded/non-rounded corners.)
        if point.isRounded {
            radius = point.customCornerRadius ?? defaultCornerRadius
        }
        path.addArc(tangent1End: point.point, tangent2End: nextPoint.point, radius: radius)
    }

    // Close the path by drawing a line from the last vertex/corner to the midpoint between the last and first point
    path.addLine(to: midpoint)

    return path
}
