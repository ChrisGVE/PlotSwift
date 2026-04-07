//
//  DrawingContext+SVG.swift
//  PlotSwift
//
//  SVG export for DrawingContext.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - SVG Export

extension DrawingContext {

  /// Render to SVG string.
  public func renderToSVG(size: CGSize) -> String {
    var svg = """
      <?xml version="1.0" encoding="UTF-8"?>
      <svg width="\(Int(size.width))" height="\(Int(size.height))" \
      xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="white"/>

      """

    var currentPath = ""
    var strokeColor = Color.black
    var fillColor = Color.clear
    var strokeWidth = 1.0
    var strokeStyle = LineStyle.solid
    var globalAlpha = 1.0
    var transformStack: [String] = []

    func currentTransformAttr() -> String {
      guard !transformStack.isEmpty else { return "" }
      return " transform=\"\(transformStack.joined(separator: " "))\""
    }

    func strokeAttrs() -> String {
      var attrs = " stroke=\"\(strokeColor.toHex())\""
      let effectiveStrokeAlpha = strokeColor.alpha * globalAlpha
      if effectiveStrokeAlpha < 1 {
        attrs += " stroke-opacity=\"\(effectiveStrokeAlpha)\""
      }
      attrs += " stroke-width=\"\(strokeWidth)\""
      if let pattern = strokeStyle.dashPattern {
        attrs += " stroke-dasharray=\"\(pattern.map { "\($0)" }.joined(separator: ","))\""
      }
      return attrs
    }

    func fillAttrs() -> String {
      if fillColor != .clear {
        var attrs = " fill=\"\(fillColor.toHex())\""
        let effectiveFillAlpha = fillColor.alpha * globalAlpha
        if effectiveFillAlpha < 1 {
          attrs += " fill-opacity=\"\(effectiveFillAlpha)\""
        }
        return attrs
      }
      return " fill=\"none\""
    }

    func flushPath() {
      if !currentPath.isEmpty {
        svg +=
          "<path d=\"\(currentPath)\"\(fillAttrs())\(strokeAttrs())\(currentTransformAttr())/>\n"
        currentPath = ""
      }
    }

    for command in commands {
      switch command {
      case .moveTo(let x, let y):
        currentPath += "M\(x),\(size.height - y) "

      case .lineTo(let x, let y):
        currentPath += "L\(x),\(size.height - y) "

      case .curveTo(let cp1x, let cp1y, let cp2x, let cp2y, let x, let y):
        currentPath +=
          "C\(cp1x),\(size.height - cp1y) \(cp2x),\(size.height - cp2y) \(x),\(size.height - y) "

      case .quadCurveTo(let cpx, let cpy, let x, let y):
        currentPath += "Q\(cpx),\(size.height - cpy) \(x),\(size.height - y) "

      case .closePath:
        currentPath += "Z "

      case .rect(let x, let y, let w, let h):
        flushPath()
        svg +=
          "<rect x=\"\(x)\" y=\"\(size.height - y - h)\" width=\"\(w)\" height=\"\(h)\"\(fillAttrs())\(strokeAttrs())\(currentTransformAttr())/>\n"

      case .ellipse(let cx, let cy, let rx, let ry):
        flushPath()
        svg +=
          "<ellipse cx=\"\(cx)\" cy=\"\(size.height - cy)\" rx=\"\(rx)\" ry=\"\(ry)\"\(fillAttrs())\(strokeAttrs())\(currentTransformAttr())/>\n"

      case .arc(let cx, let cy, let r, let startAngle, let endAngle, let clockwise):
        flushPath()
        let arcPath = arcToSVGPath(
          cx: cx, cy: cy, r: r,
          startAngle: startAngle, endAngle: endAngle,
          clockwise: clockwise, size: size)
        svg +=
          "<path d=\"\(arcPath)\"\(fillAttrs())\(strokeAttrs())\(currentTransformAttr())/>\n"

      case .text(let str, let x, let y, let style):
        flushPath()
        let escaped = escapeXML(str)
        let anchor = style.anchor.rawValue
        var fontAttrs = "font-size=\"\(style.fontSize)\""
        if style.fontFamily != "sans-serif" {
          fontAttrs += " font-family=\"\(style.fontFamily)\""
        }
        if style.fontWeight == .bold {
          fontAttrs += " font-weight=\"bold\""
        } else if style.fontWeight == .light {
          fontAttrs += " font-weight=\"300\""
        }
        let fillHex = style.color.toHex()
        var alphaAttr = ""
        let effectiveAlpha = style.color.alpha * globalAlpha
        if effectiveAlpha < 1 {
          alphaAttr = " opacity=\"\(effectiveAlpha)\""
        }
        svg +=
          "<text x=\"\(x)\" y=\"\(size.height - y)\" \(fontAttrs) text-anchor=\"\(anchor)\" fill=\"\(fillHex)\"\(alphaAttr)\(currentTransformAttr())>\(escaped)</text>\n"

      case .marker(let style, let x, let y, let markerSize):
        flushPath()
        renderMarkerToSVG(
          style, x: x, y: y, size: markerSize,
          svgHeight: size.height, fillAttrs: fillAttrs(),
          strokeAttrs: strokeAttrs(), svg: &svg)

      case .pushTransform(let transform):
        flushPath()
        let svgTransform = cgAffineTransformToSVG(transform, height: size.height)
        transformStack.append(svgTransform)

      case .popTransform:
        flushPath()
        if !transformStack.isEmpty {
          transformStack.removeLast()
        }

      case .setStrokeColor(let color):
        flushPath()
        strokeColor = color

      case .setStrokeWidth(let width):
        flushPath()
        strokeWidth = width

      case .setStrokeStyle(let style):
        flushPath()
        strokeStyle = style

      case .setFillColor(let color):
        flushPath()
        fillColor = color

      case .setAlpha(let alpha):
        flushPath()
        globalAlpha = alpha

      case .strokePath:
        flushPath()

      case .fillPath:
        flushPath()

      case .fillAndStrokePath:
        flushPath()

      case .clipRect(let x, let y, let w, let h):
        flushPath()
        let clipId = "clip\(Int.random(in: 1000...9999))"
        svg += "<defs><clipPath id=\"\(clipId)\">"
        svg +=
          "<rect x=\"\(x)\" y=\"\(size.height - y - h)\" width=\"\(w)\" height=\"\(h)\"/>"
        svg += "</clipPath></defs>\n"
        svg += "<g clip-path=\"url(#\(clipId))\">\n"

      case .resetClip:
        flushPath()
        svg += "</g>\n"

      case .saveState, .restoreState:
        flushPath()
      }
    }

    flushPath()

    svg += "</svg>"
    return svg
  }

  // MARK: - Arc to SVG Path

  private func arcToSVGPath(
    cx: Double, cy: Double, r: Double,
    startAngle: Double, endAngle: Double,
    clockwise: Bool, size: CGSize
  ) -> String {
    var angleDiff = endAngle - startAngle

    // Handle full circle
    if abs(abs(angleDiff) - 2 * .pi) < 1e-10 {
      let midAngle = startAngle + .pi
      let sx = cx + r * cos(startAngle)
      let sy = size.height - (cy + r * sin(startAngle))
      let mx = cx + r * cos(midAngle)
      let my = size.height - (cy + r * sin(midAngle))
      let sweepFlag = clockwise ? 0 : 1
      return
        "M\(sx),\(sy) A\(r),\(r) 0 0,\(sweepFlag) \(mx),\(my) A\(r),\(r) 0 0,\(sweepFlag) \(sx),\(sy)"
    }

    // Normalize angle difference
    if clockwise {
      if angleDiff > 0 { angleDiff -= 2 * .pi }
    } else {
      if angleDiff < 0 { angleDiff += 2 * .pi }
    }

    let startX = cx + r * cos(startAngle)
    let startY = size.height - (cy + r * sin(startAngle))
    let endX = cx + r * cos(endAngle)
    let endY = size.height - (cy + r * sin(endAngle))

    let largeArcFlag = abs(angleDiff) > .pi ? 1 : 0
    // SVG sweep direction is opposite to math convention due to Y-flip
    let sweepFlag = clockwise ? 0 : 1

    return "M\(startX),\(startY) A\(r),\(r) 0 \(largeArcFlag),\(sweepFlag) \(endX),\(endY)"
  }

  // MARK: - SVG Marker Rendering

  private func renderMarkerToSVG(
    _ style: MarkerStyle, x: Double, y: Double, size: Double,
    svgHeight: CGFloat, fillAttrs: String, strokeAttrs: String,
    svg: inout String
  ) {
    let half = size / 2
    let sy = svgHeight - y

    switch style {
    case .circle:
      svg +=
        "<circle cx=\"\(x)\" cy=\"\(sy)\" r=\"\(half)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .square:
      svg +=
        "<rect x=\"\(x - half)\" y=\"\(sy - half)\" width=\"\(size)\" height=\"\(size)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .diamond:
      let points =
        "\(x),\(sy - half) \(x + half),\(sy) \(x),\(sy + half) \(x - half),\(sy)"
      svg += "<polygon points=\"\(points)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .triangleUp:
      let points = "\(x),\(sy - half) \(x + half),\(sy + half) \(x - half),\(sy + half)"
      svg += "<polygon points=\"\(points)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .triangleDown:
      let points = "\(x),\(sy + half) \(x + half),\(sy - half) \(x - half),\(sy - half)"
      svg += "<polygon points=\"\(points)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .triangleLeft:
      let points = "\(x - half),\(sy) \(x + half),\(sy - half) \(x + half),\(sy + half)"
      svg += "<polygon points=\"\(points)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .triangleRight:
      let points = "\(x + half),\(sy) \(x - half),\(sy - half) \(x - half),\(sy + half)"
      svg += "<polygon points=\"\(points)\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .plus:
      svg +=
        "<line x1=\"\(x)\" y1=\"\(sy - half)\" x2=\"\(x)\" y2=\"\(sy + half)\"\(strokeAttrs)/>\n"
      svg +=
        "<line x1=\"\(x - half)\" y1=\"\(sy)\" x2=\"\(x + half)\" y2=\"\(sy)\"\(strokeAttrs)/>\n"

    case .cross:
      svg +=
        "<line x1=\"\(x - half)\" y1=\"\(sy - half)\" x2=\"\(x + half)\" y2=\"\(sy + half)\"\(strokeAttrs)/>\n"
      svg +=
        "<line x1=\"\(x + half)\" y1=\"\(sy - half)\" x2=\"\(x - half)\" y2=\"\(sy + half)\"\(strokeAttrs)/>\n"

    case .star:
      let outerR = half
      let innerR = half * 0.4
      var points: [String] = []
      for i in 0..<10 {
        let angle = Double(i) * .pi / 5 - .pi / 2
        let r = i % 2 == 0 ? outerR : innerR
        points.append("\(x + r * cos(angle)),\(sy + r * sin(angle))")
      }
      svg +=
        "<polygon points=\"\(points.joined(separator: " "))\"\(fillAttrs)\(strokeAttrs)/>\n"

    case .dot:
      let dotR = size * 0.15
      svg += "<circle cx=\"\(x)\" cy=\"\(sy)\" r=\"\(dotR)\"\(fillAttrs)/>\n"

    case .none:
      break
    }
  }

  // MARK: - Helpers

  private func cgAffineTransformToSVG(
    _ transform: CGAffineTransform, height: CGFloat
  ) -> String {
    "matrix(\(transform.a),\(-transform.b),\(-transform.c),\(transform.d),\(transform.tx),\(-transform.ty))"
  }

  private func escapeXML(_ text: String) -> String {
    var result = text
    result = result.replacingOccurrences(of: "&", with: "&amp;")
    result = result.replacingOccurrences(of: "<", with: "&lt;")
    result = result.replacingOccurrences(of: ">", with: "&gt;")
    result = result.replacingOccurrences(of: "\"", with: "&quot;")
    result = result.replacingOccurrences(of: "'", with: "&apos;")
    return result
  }
}
