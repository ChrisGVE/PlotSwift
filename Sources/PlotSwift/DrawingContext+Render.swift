//
//  DrawingContext+Render.swift
//  PlotSwift
//
//  CoreGraphics rendering for DrawingContext.
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

// MARK: - CoreGraphics Rendering

extension DrawingContext {

  /// Render all commands to a Core Graphics context.
  public func render(to context: CGContext, size: CGSize) {
    context.saveGState()

    // Set up coordinate system (origin at bottom-left, y-up for math plots)
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)

    var cgTransformStack: [CGAffineTransform] = [.identity]

    for command in commands {
      switch command {
      case .moveTo(let x, let y):
        context.move(to: CGPoint(x: x, y: y))

      case .lineTo(let x, let y):
        context.addLine(to: CGPoint(x: x, y: y))

      case .curveTo(let cp1x, let cp1y, let cp2x, let cp2y, let x, let y):
        context.addCurve(
          to: CGPoint(x: x, y: y),
          control1: CGPoint(x: cp1x, y: cp1y),
          control2: CGPoint(x: cp2x, y: cp2y)
        )

      case .quadCurveTo(let cpx, let cpy, let x, let y):
        context.addQuadCurve(
          to: CGPoint(x: x, y: y),
          control: CGPoint(x: cpx, y: cpy)
        )

      case .closePath:
        context.closePath()

      case .rect(let x, let y, let w, let h):
        context.addRect(CGRect(x: x, y: y, width: w, height: h))

      case .ellipse(let cx, let cy, let rx, let ry):
        context.addEllipse(
          in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))

      case .arc(let cx, let cy, let r, let startAngle, let endAngle, let clockwise):
        context.addArc(
          center: CGPoint(x: cx, y: cy),
          radius: r,
          startAngle: startAngle,
          endAngle: endAngle,
          clockwise: clockwise
        )

      case .text(let str, let x, let y, let style):
        renderText(str, at: CGPoint(x: x, y: y), style: style, context: context)

      case .marker(let style, let x, let y, let markerSize):
        renderMarker(
          style, at: CGPoint(x: x, y: y), size: markerSize, context: context)

      case .pushTransform(let transform):
        let combined = (cgTransformStack.last ?? .identity).concatenating(transform)
        cgTransformStack.append(combined)
        context.saveGState()
        context.concatenate(transform)

      case .popTransform:
        if cgTransformStack.count > 1 {
          cgTransformStack.removeLast()
        }
        context.restoreGState()

      case .setStrokeColor(let color):
        context.setStrokeColor(color.cgColor)

      case .setStrokeWidth(let width):
        context.setLineWidth(width)

      case .setStrokeStyle(let style):
        if let pattern = style.dashPattern {
          context.setLineDash(phase: 0, lengths: pattern)
        } else {
          context.setLineDash(phase: 0, lengths: [])
        }

      case .setFillColor(let color):
        context.setFillColor(color.cgColor)

      case .setAlpha(let alpha):
        context.setAlpha(alpha)

      case .strokePath:
        context.strokePath()

      case .fillPath:
        context.fillPath()

      case .fillAndStrokePath:
        context.drawPath(using: .fillStroke)

      case .clipRect(let x, let y, let w, let h):
        context.clip(to: CGRect(x: x, y: y, width: w, height: h))

      case .resetClip:
        context.resetClip()

      case .saveState:
        context.saveGState()

      case .restoreState:
        context.restoreGState()
      }
    }

    context.restoreGState()
  }

  // MARK: - Text Rendering

  private func renderText(
    _ string: String, at point: CGPoint, style: TextStyle, context: CGContext
  ) {
    context.saveGState()

    // Flip for text (text renders upside-down in flipped context)
    context.translateBy(x: point.x, y: point.y)
    context.scaleBy(x: 1, y: -1)

    let font = makeCTFont(style: style)

    let attributes: [CFString: Any] = [
      kCTFontAttributeName: font,
      kCTForegroundColorAttributeName: style.color.cgColor,
    ]

    let attrString = CFAttributedStringCreate(
      nil,
      string as CFString,
      attributes as CFDictionary
    )!

    let line = CTLineCreateWithAttributedString(attrString)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)

    var xOffset: CGFloat = 0
    switch style.anchor {
    case .middle:
      xOffset = -bounds.width / 2
    case .end:
      xOffset = -bounds.width
    case .start:
      xOffset = 0
    }

    context.textPosition = CGPoint(x: xOffset, y: -bounds.height / 4)
    CTLineDraw(line, context)

    context.restoreGState()
  }

  private func makeCTFont(style: TextStyle) -> CTFont {
    // Try to create font from specified family first
    let requestedFont = CTFontCreateWithName(
      style.fontFamily as CFString, style.fontSize, nil)

    var traits: CTFontSymbolicTraits = []
    switch style.fontWeight {
    case .bold:
      traits.insert(.boldTrait)
    case .light:
      break
    case .normal:
      break
    }

    let baseFont: CTFont
    if style.fontFamily == "sans-serif" {
      #if os(macOS)
        baseFont =
          CTFontCreateUIFontForLanguage(.system, style.fontSize, nil)
          ?? CTFontCreateWithName("Helvetica" as CFString, style.fontSize, nil)
      #else
        baseFont = CTFontCreateWithName("Helvetica" as CFString, style.fontSize, nil)
      #endif
    } else {
      baseFont = requestedFont
    }

    if !traits.isEmpty {
      if let descriptor = CTFontCopyFontDescriptor(baseFont) as CTFontDescriptor?,
        let styledDescriptor = CTFontDescriptorCreateCopyWithSymbolicTraits(
          descriptor, traits, traits)
      {
        return CTFontCreateWithFontDescriptor(styledDescriptor, style.fontSize, nil)
      }
    }

    return baseFont
  }

}

// MARK: - Export to Image

#if canImport(ImageIO)
  extension DrawingContext {

    /// Render to PNG data.
    public func renderToPNG(size: CGSize, scale: CGFloat = 1.0) -> Data? {
      let width = Int(size.width * scale)
      let height = Int(size.height * scale)

      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

      guard
        let context = CGContext(
          data: nil,
          width: width,
          height: height,
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: bitmapInfo
        )
      else { return nil }

      context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
      context.fill(CGRect(x: 0, y: 0, width: width, height: height))

      context.scaleBy(x: scale, y: scale)

      render(to: context, size: size)

      guard let image = context.makeImage() else { return nil }

      let data = NSMutableData()
      #if canImport(UniformTypeIdentifiers)
        guard
          let dest = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.png.identifier as CFString,
            1, nil
          )
        else { return nil }
      #else
        guard
          let dest = CGImageDestinationCreateWithData(
            data as CFMutableData,
            kUTTypePNG,
            1, nil
          )
        else { return nil }
      #endif

      CGImageDestinationAddImage(dest, image, nil)
      guard CGImageDestinationFinalize(dest) else { return nil }

      return data as Data
    }

    /// Render to PDF data.
    public func renderToPDF(size: CGSize) -> Data? {
      let data = NSMutableData()

      var mediaBox = CGRect(origin: .zero, size: size)

      guard let consumer = CGDataConsumer(data: data as CFMutableData),
        let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
      else { return nil }

      context.beginPDFPage(nil)
      render(to: context, size: size)
      context.endPDFPage()
      context.closePDF()

      return data as Data
    }
  }
#endif
