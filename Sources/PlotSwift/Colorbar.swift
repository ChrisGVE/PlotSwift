//
//  Colorbar.swift
//  PlotSwift
//
//  Colorbar widget that renders a gradient legend with tick marks.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Orientation

/// The orientation of a colorbar or similar widget.
public enum Orientation: Sendable {
  /// Taller than wide; gradient runs bottom-to-top.
  case vertical
  /// Wider than tall; gradient runs left-to-right.
  case horizontal
}

// MARK: - Colorbar

/// A colorbar widget that maps scalar values to colors via a ``ColorPalette``.
///
/// ```swift
/// let cb = Colorbar(palette: .viridis, vmin: 0, vmax: 1)
/// cb.label = "Intensity"
/// cb.render(to: ctx, in: CGRect(x: 820, y: 50, width: 20, height: 500))
/// ```
public final class Colorbar {

  // MARK: Public properties

  /// The color palette used for the gradient.
  public let palette: ColorPalette

  /// Scalar value that maps to the low end of the palette.
  public let vmin: Double

  /// Scalar value that maps to the high end of the palette.
  public let vmax: Double

  /// Optional axis label drawn alongside the gradient bar.
  public var label: String?

  /// Whether the gradient is rendered vertically or horizontally.
  public var orientation: Orientation

  /// Explicit tick positions in data units; `nil` uses auto-generated ticks.
  public var tickPositions: [Double]?

  // MARK: Private constants

  private static let stripeCount = 256
  private static let tickLength: Double = 4
  private static let tickGap: Double = 3
  private static let tickFontSize: Double = 10
  private static let labelFontSize: Double = 11

  // MARK: Init

  /// Creates a colorbar.
  /// - Parameters:
  ///   - palette: The continuous palette for gradient rendering.
  ///   - vmin: Data value at the low end.
  ///   - vmax: Data value at the high end.
  ///   - label: Optional axis label.
  ///   - orientation: `.vertical` (default) or `.horizontal`.
  public init(
    palette: ColorPalette,
    vmin: Double,
    vmax: Double,
    label: String? = nil,
    orientation: Orientation = .vertical
  ) {
    self.palette = palette
    self.vmin = vmin
    self.vmax = vmax
    self.label = label
    self.orientation = orientation
  }

  // MARK: Rendering

  /// Renders the colorbar into `context` within `rect`.
  ///
  /// - Parameters:
  ///   - context: The drawing context to append commands to.
  ///   - rect: The bounding rectangle for the entire colorbar widget.
  public func render(to context: DrawingContext, in rect: CGRect) {
    context.saveState()
    drawGradient(to: context, in: rect)
    drawBorder(to: context, in: rect)
    drawTicks(to: context, in: rect)
    if let labelText = label {
      drawLabel(labelText, to: context, in: rect)
    }
    context.restoreState()
  }

  // MARK: Private rendering helpers

  private func drawGradient(to ctx: DrawingContext, in rect: CGRect) {
    let n = Self.stripeCount
    for i in 0..<n {
      let t = Double(i) / Double(n - 1)
      let color = palette.color(at: t)
      ctx.setFillColor(color)
      let stripeRect = stripeRect(index: i, count: n, in: rect)
      ctx.rect(
        Double(stripeRect.origin.x),
        Double(stripeRect.origin.y),
        Double(stripeRect.width),
        Double(stripeRect.height)
      )
      ctx.fillPath()
    }
  }

  private func drawBorder(to ctx: DrawingContext, in rect: CGRect) {
    ctx.setStrokeColor(.black)
    ctx.setStrokeWidth(0.5)
    ctx.rect(
      Double(rect.origin.x), Double(rect.origin.y),
      Double(rect.width), Double(rect.height)
    )
    ctx.strokePath()
  }

  private func drawTicks(to ctx: DrawingContext, in rect: CGRect) {
    let ticks = resolvedTicks()
    let tickStyle = TextStyle(
      fontSize: Self.tickFontSize,
      anchor: orientation == .vertical ? .start : .middle
    )
    ctx.setStrokeColor(.black)
    ctx.setStrokeWidth(0.5)

    for value in ticks where value >= vmin && value <= vmax {
      let t = (value - vmin) / (vmax - vmin)
      renderTick(t: t, value: value, style: tickStyle, to: ctx, in: rect)
    }
  }

  private func renderTick(
    t: Double, value: Double, style: TextStyle,
    to ctx: DrawingContext, in rect: CGRect
  ) {
    let formatter = DefaultTickFormatter()
    let labelStr = formatter.format(value)
    let tLen = Self.tickLength
    let gap = Self.tickGap

    if orientation == .vertical {
      let y = Double(rect.maxY) - t * Double(rect.height)
      let x1 = Double(rect.maxX)
      ctx.moveTo(x1, y)
      ctx.lineTo(x1 + tLen, y)
      ctx.strokePath()
      ctx.text(labelStr, x: x1 + tLen + gap, y: y - Self.tickFontSize * 0.35, style: style)
    } else {
      let x = Double(rect.minX) + t * Double(rect.width)
      let y1 = Double(rect.minY)
      ctx.moveTo(x, y1)
      ctx.lineTo(x, y1 - tLen)
      ctx.strokePath()
      ctx.text(labelStr, x: x, y: y1 - tLen - gap, style: style)
    }
  }

  private func drawLabel(_ text: String, to ctx: DrawingContext, in rect: CGRect) {
    let style = TextStyle(fontSize: Self.labelFontSize, fontWeight: .bold, anchor: .middle)
    if orientation == .vertical {
      let cx = Double(rect.maxX) + 40
      let cy = Double(rect.midY)
      ctx.translate(cx, cy)
      ctx.rotate(-.pi / 2)
      ctx.text(text, x: 0, y: 0, style: style)
      ctx.popTransform()
      ctx.popTransform()
    } else {
      let cx = Double(rect.midX)
      let cy = Double(rect.minY) - 28
      ctx.text(text, x: cx, y: cy, style: style)
    }
  }

  private func stripeRect(index: Int, count: Int, in rect: CGRect) -> CGRect {
    if orientation == .vertical {
      let stripeH = rect.height / CGFloat(count)
      let y = rect.maxY - CGFloat(index + 1) * stripeH
      return CGRect(x: rect.origin.x, y: y, width: rect.width, height: stripeH + 0.5)
    } else {
      let stripeW = rect.width / CGFloat(count)
      let x = rect.origin.x + CGFloat(index) * stripeW
      return CGRect(x: x, y: rect.origin.y, width: stripeW + 0.5, height: rect.height)
    }
  }

  private func resolvedTicks() -> [Double] {
    if let explicit = tickPositions { return explicit }
    let range = DataRange(min: vmin, max: vmax)
    return TickGenerator().generateTicks(range: range, maxTicks: 6)
  }
}

// MARK: - Axes + Colorbar

extension Axes {

  /// Attaches a colorbar to this axes and returns it.
  ///
  /// - Parameters:
  ///   - palette: The continuous palette for the gradient.
  ///   - vmin: Data value at the low end.
  ///   - vmax: Data value at the high end.
  ///   - label: Optional axis label.
  ///   - orientation: `.vertical` (default) or `.horizontal`.
  /// - Returns: The created ``Colorbar`` (discardable).
  @discardableResult
  public func colorbar(
    palette: ColorPalette,
    vmin: Double,
    vmax: Double,
    label: String? = nil,
    orientation: Orientation = .vertical
  ) -> Colorbar {
    let cb = Colorbar(
      palette: palette, vmin: vmin, vmax: vmax,
      label: label, orientation: orientation
    )
    self.colorbar = cb
    return cb
  }
}
