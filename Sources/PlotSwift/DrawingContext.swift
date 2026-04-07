//
//  DrawingContext.swift
//  PlotSwift
//
//  Retained-mode drawing context for vector graphics.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import CoreText
import Foundation

#if canImport(ImageIO)
  import ImageIO
#endif
#if canImport(UniformTypeIdentifiers)
  import UniformTypeIdentifiers
#endif
#if os(macOS)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

// MARK: - DrawingContext

/// A retained-mode drawing context that stores vector commands for scale-free rendering.
///
/// DrawingContext is the primary interface for creating vector graphics in PlotSwift.
/// All drawing operations are stored as ``DrawingCommand`` instances that can later
/// be rendered to PNG, PDF, or SVG at any resolution.
///
/// ## Basic Usage
///
/// ```swift
/// let ctx = DrawingContext()
///
/// // Draw a filled rectangle
/// ctx.setFillColor(.blue)
/// ctx.rect(50, 50, 200, 150)
/// ctx.fillPath()
///
/// // Export to PNG
/// let data = ctx.renderToPNG(size: CGSize(width: 400, height: 300))
/// ```
///
/// ## Coordinate System
///
/// The coordinate system uses mathematical conventions: origin at bottom-left,
/// y-axis pointing upward. This is automatically converted to screen coordinates
/// during rendering.
public final class DrawingContext {
  /// All drawing commands stored in execution order.
  public private(set) var commands: [DrawingCommand] = []

  /// Transform stack for nested coordinate systems.
  private var transformStack: [CGAffineTransform] = [.identity]

  /// The current transformation matrix (top of the transform stack).
  public var currentTransform: CGAffineTransform {
    transformStack.last ?? .identity
  }

  /// The bounding rectangle of all drawing commands.
  ///
  /// Computes the minimal rectangle that contains all drawn content.
  /// Returns `.zero` if no drawing commands have been added.
  public var bounds: CGRect {
    var minX = Double.infinity
    var minY = Double.infinity
    var maxX = -Double.infinity
    var maxY = -Double.infinity

    for command in commands {
      switch command {
      case .moveTo(let x, let y), .lineTo(let x, let y):
        minX = Swift.min(minX, x)
        minY = Swift.min(minY, y)
        maxX = Swift.max(maxX, x)
        maxY = Swift.max(maxY, y)
      case .curveTo(let cp1x, let cp1y, let cp2x, let cp2y, let x, let y):
        for px in [cp1x, cp2x, x] {
          minX = Swift.min(minX, px)
          maxX = Swift.max(maxX, px)
        }
        for py in [cp1y, cp2y, y] {
          minY = Swift.min(minY, py)
          maxY = Swift.max(maxY, py)
        }
      case .quadCurveTo(let cpx, let cpy, let x, let y):
        for px in [cpx, x] {
          minX = Swift.min(minX, px)
          maxX = Swift.max(maxX, px)
        }
        for py in [cpy, y] {
          minY = Swift.min(minY, py)
          maxY = Swift.max(maxY, py)
        }
      case .rect(let x, let y, let w, let h):
        minX = Swift.min(minX, x)
        minY = Swift.min(minY, y)
        maxX = Swift.max(maxX, x + w)
        maxY = Swift.max(maxY, y + h)
      case .ellipse(let cx, let cy, let rx, let ry):
        minX = Swift.min(minX, cx - rx)
        minY = Swift.min(minY, cy - ry)
        maxX = Swift.max(maxX, cx + rx)
        maxY = Swift.max(maxY, cy + ry)
      case .arc(let cx, let cy, let r, _, _, _):
        minX = Swift.min(minX, cx - r)
        minY = Swift.min(minY, cy - r)
        maxX = Swift.max(maxX, cx + r)
        maxY = Swift.max(maxY, cy + r)
      case .text(_, let x, let y, _):
        minX = Swift.min(minX, x)
        minY = Swift.min(minY, y)
        maxX = Swift.max(maxX, x)
        maxY = Swift.max(maxY, y)
      case .marker(_, let x, let y, let size):
        let half = size / 2
        minX = Swift.min(minX, x - half)
        minY = Swift.min(minY, y - half)
        maxX = Swift.max(maxX, x + half)
        maxY = Swift.max(maxY, y + half)
      default:
        break
      }
    }

    if minX == Double.infinity {
      return .zero
    }
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }

  public init() {}

  /// Clear all commands
  public func clear() {
    commands.removeAll()
    transformStack = [.identity]
  }

  /// Number of commands
  public var commandCount: Int {
    commands.count
  }

  // MARK: - Path Construction

  public func moveTo(_ x: Double, _ y: Double) {
    commands.append(.moveTo(x: x, y: y))
  }

  public func lineTo(_ x: Double, _ y: Double) {
    commands.append(.lineTo(x: x, y: y))
  }

  public func curveTo(
    cp1x: Double, cp1y: Double,
    cp2x: Double, cp2y: Double,
    x: Double, y: Double
  ) {
    commands.append(.curveTo(cp1x: cp1x, cp1y: cp1y, cp2x: cp2x, cp2y: cp2y, x: x, y: y))
  }

  public func quadCurveTo(cpx: Double, cpy: Double, x: Double, y: Double) {
    commands.append(.quadCurveTo(cpx: cpx, cpy: cpy, x: x, y: y))
  }

  public func closePath() {
    commands.append(.closePath)
  }

  // MARK: - Shapes

  public func rect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
    commands.append(.rect(x: x, y: y, width: width, height: height))
  }

  public func ellipse(cx: Double, cy: Double, rx: Double, ry: Double) {
    commands.append(.ellipse(cx: cx, cy: cy, rx: rx, ry: ry))
  }

  public func circle(cx: Double, cy: Double, r: Double) {
    ellipse(cx: cx, cy: cy, rx: r, ry: r)
  }

  public func arc(
    cx: Double, cy: Double, r: Double,
    startAngle: Double, endAngle: Double,
    clockwise: Bool = false
  ) {
    commands.append(
      .arc(
        cx: cx, cy: cy, r: r,
        startAngle: startAngle, endAngle: endAngle,
        clockwise: clockwise
      ))
  }

  // MARK: - Text

  public func text(_ string: String, x: Double, y: Double, style: TextStyle = TextStyle()) {
    commands.append(.text(string, x: x, y: y, style: style))
  }

  // MARK: - Markers

  /// Draw a marker at the specified position.
  public func drawMarker(
    style: MarkerStyle, x: Double, y: Double, size: Double = 6.0
  ) {
    guard style != .none else { return }
    commands.append(.marker(style: style, x: x, y: y, size: size))
  }

  // MARK: - Transform Stack

  public func pushTransform(_ transform: CGAffineTransform) {
    let combined = currentTransform.concatenating(transform)
    transformStack.append(combined)
    commands.append(.pushTransform(transform))
  }

  public func popTransform() {
    if transformStack.count > 1 {
      transformStack.removeLast()
    }
    commands.append(.popTransform)
  }

  public func translate(_ tx: Double, _ ty: Double) {
    pushTransform(CGAffineTransform(translationX: tx, y: ty))
  }

  public func scale(_ sx: Double, _ sy: Double) {
    pushTransform(CGAffineTransform(scaleX: sx, y: sy))
  }

  public func rotate(_ angle: Double) {
    pushTransform(CGAffineTransform(rotationAngle: angle))
  }

  // MARK: - Style State

  public func setStrokeColor(_ color: Color) {
    commands.append(.setStrokeColor(color))
  }

  public func setStrokeWidth(_ width: Double) {
    commands.append(.setStrokeWidth(width))
  }

  public func setStrokeStyle(_ style: LineStyle) {
    commands.append(.setStrokeStyle(style))
  }

  public func setFillColor(_ color: Color) {
    commands.append(.setFillColor(color))
  }

  public func setAlpha(_ alpha: Double) {
    commands.append(.setAlpha(alpha))
  }

  // MARK: - Drawing Operations

  public func strokePath() {
    commands.append(.strokePath)
  }

  public func fillPath() {
    commands.append(.fillPath)
  }

  public func fillAndStrokePath() {
    commands.append(.fillAndStrokePath)
  }

  // MARK: - State Management

  public func saveState() {
    commands.append(.saveState)
  }

  public func restoreState() {
    commands.append(.restoreState)
  }

  // MARK: - Clipping

  public func clipRect(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
    commands.append(.clipRect(x: x, y: y, width: width, height: height))
  }

  public func resetClip() {
    commands.append(.resetClip)
  }
}
