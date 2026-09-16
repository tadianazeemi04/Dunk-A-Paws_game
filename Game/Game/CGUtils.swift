import Foundation
import CoreGraphics
import SpriteKit

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func += (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}

func + (lhs: CGVector, rhs: CGVector) -> CGVector {
    CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

func * (vec: CGVector, scalar: CGFloat) -> CGVector {
    CGVector(dx: vec.dx * scalar, dy: vec.dy * scalar)
}
