//
//  DrawingCommand.swift
//  PlotSwift
//
//  Vector graphics operations for the retained-mode drawing system.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics

// MARK: - DrawingCommand

/// A single vector graphics operation stored in a ``DrawingContext``.
///
/// DrawingCommand represents all the operations that can be recorded
/// and later rendered. This retained-mode architecture enables scale-free
/// rendering and export to multiple formats.
public enum DrawingCommand: Equatable, Sendable {
  // Path construction
  case moveTo(x: Double, y: Double)
  case lineTo(x: Double, y: Double)
  case curveTo(cp1x: Double, cp1y: Double, cp2x: Double, cp2y: Double, x: Double, y: Double)
  case quadCurveTo(cpx: Double, cpy: Double, x: Double, y: Double)
  case closePath

  // Shapes
  case rect(x: Double, y: Double, width: Double, height: Double)
  case ellipse(cx: Double, cy: Double, rx: Double, ry: Double)
  case arc(
    cx: Double, cy: Double, r: Double, startAngle: Double, endAngle: Double,
    clockwise: Bool)

  // Text
  case text(String, x: Double, y: Double, style: TextStyle)

  // Markers
  case marker(style: MarkerStyle, x: Double, y: Double, size: Double)

  // Transform stack
  case pushTransform(CGAffineTransform)
  case popTransform

  // Style state
  case setStrokeColor(Color)
  case setStrokeWidth(Double)
  case setStrokeStyle(LineStyle)
  case setFillColor(Color)
  case setAlpha(Double)

  // Drawing operations
  case strokePath
  case fillPath
  case fillAndStrokePath

  // Clipping
  case clipRect(x: Double, y: Double, width: Double, height: Double)
  case resetClip

  // Save/restore graphics state
  case saveState
  case restoreState
}
