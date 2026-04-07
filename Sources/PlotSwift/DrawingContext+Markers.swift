//
//  DrawingContext+Markers.swift
//  PlotSwift
//
//  Marker shape rendering for DrawingContext.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Marker Rendering

extension DrawingContext {

  /// Renders a single marker shape into the given Core Graphics context.
  /// - Parameters:
  ///   - style: The marker shape to draw.
  ///   - point: The center of the marker in pixel coordinates.
  ///   - size: The bounding size of the marker.
  ///   - context: The Core Graphics context that receives the drawing commands.
  func renderMarker(
    _ style: MarkerStyle, at point: CGPoint, size: Double, context: CGContext
  ) {
    let half = size / 2
    let x = point.x
    let y = point.y

    context.saveGState()

    switch style {
    case .circle:
      context.addEllipse(
        in: CGRect(x: x - half, y: y - half, width: size, height: size))
      context.drawPath(using: .fillStroke)

    case .square:
      context.addRect(
        CGRect(x: x - half, y: y - half, width: size, height: size))
      context.drawPath(using: .fillStroke)

    case .diamond:
      context.move(to: CGPoint(x: x, y: y - half))
      context.addLine(to: CGPoint(x: x + half, y: y))
      context.addLine(to: CGPoint(x: x, y: y + half))
      context.addLine(to: CGPoint(x: x - half, y: y))
      context.closePath()
      context.drawPath(using: .fillStroke)

    case .triangleUp:
      context.move(to: CGPoint(x: x, y: y - half))
      context.addLine(to: CGPoint(x: x + half, y: y + half))
      context.addLine(to: CGPoint(x: x - half, y: y + half))
      context.closePath()
      context.drawPath(using: .fillStroke)

    case .triangleDown:
      context.move(to: CGPoint(x: x, y: y + half))
      context.addLine(to: CGPoint(x: x + half, y: y - half))
      context.addLine(to: CGPoint(x: x - half, y: y - half))
      context.closePath()
      context.drawPath(using: .fillStroke)

    case .triangleLeft:
      context.move(to: CGPoint(x: x - half, y: y))
      context.addLine(to: CGPoint(x: x + half, y: y - half))
      context.addLine(to: CGPoint(x: x + half, y: y + half))
      context.closePath()
      context.drawPath(using: .fillStroke)

    case .triangleRight:
      context.move(to: CGPoint(x: x + half, y: y))
      context.addLine(to: CGPoint(x: x - half, y: y - half))
      context.addLine(to: CGPoint(x: x - half, y: y + half))
      context.closePath()
      context.drawPath(using: .fillStroke)

    case .plus:
      context.move(to: CGPoint(x: x, y: y - half))
      context.addLine(to: CGPoint(x: x, y: y + half))
      context.move(to: CGPoint(x: x - half, y: y))
      context.addLine(to: CGPoint(x: x + half, y: y))
      context.strokePath()

    case .cross:
      context.move(to: CGPoint(x: x - half, y: y - half))
      context.addLine(to: CGPoint(x: x + half, y: y + half))
      context.move(to: CGPoint(x: x + half, y: y - half))
      context.addLine(to: CGPoint(x: x - half, y: y + half))
      context.strokePath()

    case .star:
      renderStarMarker(x: x, y: y, half: half, context: context)

    case .dot:
      let dotSize = size * 0.3
      context.addEllipse(
        in: CGRect(
          x: x - dotSize / 2, y: y - dotSize / 2,
          width: dotSize, height: dotSize))
      context.drawPath(using: .fill)

    case .none:
      break
    }

    context.restoreGState()
  }

  private func renderStarMarker(x: Double, y: Double, half: Double, context: CGContext) {
    let outerR = half
    let innerR = half * 0.4
    var starPath: [CGPoint] = []
    for i in 0..<10 {
      let angle = Double(i) * .pi / 5 - .pi / 2
      let r = i % 2 == 0 ? outerR : innerR
      starPath.append(CGPoint(x: x + r * cos(angle), y: y + r * sin(angle)))
    }
    context.move(to: starPath[0])
    for pt in starPath.dropFirst() {
      context.addLine(to: pt)
    }
    context.closePath()
    context.drawPath(using: .fillStroke)
  }
}
