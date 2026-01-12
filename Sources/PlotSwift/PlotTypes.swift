//
//  PlotTypes.swift
//  PlotSwift
//
//  Extracted from LuaSwift PlotModule
//  Original work Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//
//  Licensed under the MIT License.
//

import Foundation
import CoreGraphics
import CoreText
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

// MARK: - Color

/// A color representation for plotting.
public struct Color: Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Create color from hex string (e.g., "#FF0000" or "FF0000")
    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if hexSanitized.count == 6 {
            self.red = Double((rgb & 0xFF0000) >> 16) / 255.0
            self.green = Double((rgb & 0x00FF00) >> 8) / 255.0
            self.blue = Double(rgb & 0x0000FF) / 255.0
            self.alpha = 1.0
        } else if hexSanitized.count == 8 {
            self.red = Double((rgb & 0xFF000000) >> 24) / 255.0
            self.green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            self.blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            self.alpha = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
    }

    /// Create color from name
    public init?(name: String) {
        switch name.lowercased() {
        case "black": self = .black
        case "white": self = .white
        case "red": self = .red
        case "green": self = .green
        case "blue": self = .blue
        case "yellow": self = .yellow
        case "cyan": self = .cyan
        case "magenta": self = .magenta
        case "orange": self = .orange
        case "purple": self = .purple
        case "brown": self = .brown
        case "pink": self = .pink
        case "gray", "grey": self = .gray
        case "lightgray", "lightgrey": self = .lightGray
        case "darkgray", "darkgrey": self = .darkGray
        case "none", "transparent": self = .clear
        default: return nil
        }
    }

    public var cgColor: CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    public func toHex(includeAlpha: Bool = false) -> String {
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        if includeAlpha {
            let a = Int(alpha * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    // Predefined colors
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 0.5, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1)
    public static let yellow = Color(red: 1, green: 1, blue: 0)
    public static let cyan = Color(red: 0, green: 1, blue: 1)
    public static let magenta = Color(red: 1, green: 0, blue: 1)
    public static let orange = Color(red: 1, green: 0.647, blue: 0)
    public static let purple = Color(red: 0.5, green: 0, blue: 0.5)
    public static let brown = Color(red: 0.647, green: 0.165, blue: 0.165)
    public static let pink = Color(red: 1, green: 0.753, blue: 0.796)
    public static let gray = Color(red: 0.5, green: 0.5, blue: 0.5)
    public static let lightGray = Color(red: 0.75, green: 0.75, blue: 0.75)
    public static let darkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}

// MARK: - TextStyle

/// Text styling for rendering
public struct TextStyle: Equatable, Sendable {
    public var fontFamily: String
    public var fontSize: Double
    public var fontWeight: FontWeight
    public var color: Color
    public var anchor: TextAnchor

    public enum FontWeight: String, Sendable {
        case normal = "normal"
        case bold = "bold"
        case light = "light"
    }

    public enum TextAnchor: String, Sendable {
        case start = "start"
        case middle = "middle"
        case end = "end"
    }

    public init(
        fontFamily: String = "sans-serif",
        fontSize: Double = 12,
        fontWeight: FontWeight = .normal,
        color: Color = .black,
        anchor: TextAnchor = .start
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.color = color
        self.anchor = anchor
    }
}

// MARK: - LineStyle

/// Line style for strokes
public enum LineStyle: String, Sendable {
    case solid = "-"
    case dashed = "--"
    case dotted = ":"
    case dashDot = "-."
    case none = ""

    public var dashPattern: [CGFloat]? {
        switch self {
        case .solid, .none: return nil
        case .dashed: return [6, 4]
        case .dotted: return [2, 2]
        case .dashDot: return [6, 2, 2, 2]
        }
    }
}

// MARK: - MarkerStyle

/// Marker style for scatter points
public enum MarkerStyle: String, Sendable {
    case circle = "o"
    case square = "s"
    case diamond = "D"
    case triangleUp = "^"
    case triangleDown = "v"
    case triangleLeft = "<"
    case triangleRight = ">"
    case plus = "+"
    case cross = "x"
    case star = "*"
    case dot = "."
    case none = ""
}

// MARK: - DrawingCommand

/// Drawing command representing a single vector graphics operation
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
    case arc(cx: Double, cy: Double, r: Double, startAngle: Double, endAngle: Double, clockwise: Bool)

    // Text
    case text(String, x: Double, y: Double, style: TextStyle)

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

// MARK: - DrawingContext

/// DrawingContext holds retained vector commands for scale-free rendering
public final class DrawingContext {
    /// All drawing commands stored in order
    public private(set) var commands: [DrawingCommand] = []

    /// Transform stack for nested coordinate systems
    private var transformStack: [CGAffineTransform] = [.identity]

    /// Current transform (top of stack)
    public var currentTransform: CGAffineTransform {
        transformStack.last ?? .identity
    }

    /// Computed bounds from all drawing commands
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
            case .text(_, let x, let y, _):
                minX = Swift.min(minX, x)
                minY = Swift.min(minY, y)
                maxX = Swift.max(maxX, x)
                maxY = Swift.max(maxY, y)
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

    public func curveTo(cp1x: Double, cp1y: Double, cp2x: Double, cp2y: Double, x: Double, y: Double) {
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

    public func arc(cx: Double, cy: Double, r: Double, startAngle: Double, endAngle: Double, clockwise: Bool = false) {
        commands.append(.arc(cx: cx, cy: cy, r: r, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise))
    }

    // MARK: - Text

    public func text(_ string: String, x: Double, y: Double, style: TextStyle = TextStyle()) {
        commands.append(.text(string, x: x, y: y, style: style))
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

    // MARK: - Rendering

    /// Render all commands to a Core Graphics context
    public func render(to context: CGContext, size: CGSize) {
        context.saveGState()

        // Set up coordinate system (origin at bottom-left, y-up for math plots)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        var transformStack: [CGAffineTransform] = [.identity]

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
                context.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))

            case .arc(let cx, let cy, let r, let startAngle, let endAngle, let clockwise):
                context.addArc(
                    center: CGPoint(x: cx, y: cy),
                    radius: r,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: clockwise
                )

            case .text(let str, let x, let y, let style):
                renderText(str, at: CGPoint(x: x, y: y), style: style, context: context, size: size)

            case .pushTransform(let transform):
                let combined = (transformStack.last ?? .identity).concatenating(transform)
                transformStack.append(combined)
                context.saveGState()
                context.concatenate(transform)

            case .popTransform:
                if transformStack.count > 1 {
                    transformStack.removeLast()
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

    /// Render text with proper font handling using CoreText
    private func renderText(_ string: String, at point: CGPoint, style: TextStyle, context: CGContext, size: CGSize) {
        context.saveGState()

        // Flip for text (text renders upside-down in flipped context)
        context.translateBy(x: point.x, y: point.y)
        context.scaleBy(x: 1, y: -1)

        // Create font using CoreText
        let font = makeCTFont(style: style)

        // Create attributed string with CoreText attributes
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: style.color.cgColor
        ]

        let attrString = CFAttributedStringCreate(
            nil,
            string as CFString,
            attributes as CFDictionary
        )!

        let line = CTLineCreateWithAttributedString(attrString)
        let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)

        // Adjust x position based on anchor
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

    /// Create a CTFont with the specified style
    private func makeCTFont(style: TextStyle) -> CTFont {
        var traits: CTFontSymbolicTraits = []
        switch style.fontWeight {
        case .bold:
            traits.insert(.boldTrait)
        case .light:
            // Light weight not directly supported via traits, use system font
            break
        case .normal:
            break
        }

        // Create system font
        #if os(macOS)
        let systemFont = CTFontCreateUIFontForLanguage(.system, style.fontSize, nil) ?? CTFontCreateWithName("Helvetica" as CFString, style.fontSize, nil)
        #else
        let systemFont = CTFontCreateWithName("Helvetica" as CFString, style.fontSize, nil)
        #endif

        // Apply traits if needed
        if !traits.isEmpty {
            if let descriptor = CTFontCopyFontDescriptor(systemFont) as CTFontDescriptor?,
               let styledDescriptor = CTFontDescriptorCreateCopyWithSymbolicTraits(descriptor, traits, traits) {
                return CTFontCreateWithFontDescriptor(styledDescriptor, style.fontSize, nil)
            }
        }

        return systemFont
    }

    // MARK: - Export to Image

    #if canImport(ImageIO)
    /// Render to PNG data
    public func renderToPNG(size: CGSize, scale: CGFloat = 1.0) -> Data? {
        let width = Int(size.width * scale)
        let height = Int(size.height * scale)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        // Fill with white background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Scale for DPI
        context.scaleBy(x: scale, y: scale)

        // Render commands
        render(to: context, size: size)

        guard let image = context.makeImage() else { return nil }

        // Encode to PNG
        let data = NSMutableData()
        #if canImport(UniformTypeIdentifiers)
        guard let dest = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.png.identifier as CFString,
            1, nil
        ) else { return nil }
        #else
        guard let dest = CGImageDestinationCreateWithData(
            data as CFMutableData,
            kUTTypePNG,
            1, nil
        ) else { return nil }
        #endif

        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { return nil }

        return data as Data
    }

    /// Render to PDF data
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
    #endif

    // MARK: - Export to SVG

    /// Render to SVG string
    public func renderToSVG(size: CGSize) -> String {
        var svg = """
        <?xml version="1.0" encoding="UTF-8"?>
        <svg width="\(Int(size.width))" height="\(Int(size.height))" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="white"/>

        """

        var currentPath = ""
        var strokeColor = Color.black
        var fillColor = Color.clear
        var strokeWidth = 1.0
        var strokeStyle = LineStyle.solid

        func flushPath() {
            if !currentPath.isEmpty {
                var attrs = "d=\"\(currentPath)\""

                if fillColor != .clear {
                    attrs += " fill=\"\(fillColor.toHex())\""
                    if fillColor.alpha < 1 {
                        attrs += " fill-opacity=\"\(fillColor.alpha)\""
                    }
                } else {
                    attrs += " fill=\"none\""
                }

                attrs += " stroke=\"\(strokeColor.toHex())\""
                if strokeColor.alpha < 1 {
                    attrs += " stroke-opacity=\"\(strokeColor.alpha)\""
                }
                attrs += " stroke-width=\"\(strokeWidth)\""

                if let pattern = strokeStyle.dashPattern {
                    attrs += " stroke-dasharray=\"\(pattern.map { "\($0)" }.joined(separator: ","))\""
                }

                svg += "<path \(attrs)/>\n"
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
                currentPath += "C\(cp1x),\(size.height - cp1y) \(cp2x),\(size.height - cp2y) \(x),\(size.height - y) "

            case .quadCurveTo(let cpx, let cpy, let x, let y):
                currentPath += "Q\(cpx),\(size.height - cpy) \(x),\(size.height - y) "

            case .closePath:
                currentPath += "Z "

            case .rect(let x, let y, let w, let h):
                flushPath()
                let fillAttr = fillColor != .clear ? "fill=\"\(fillColor.toHex())\"" : "fill=\"none\""
                let strokeAttr = "stroke=\"\(strokeColor.toHex())\" stroke-width=\"\(strokeWidth)\""
                svg += "<rect x=\"\(x)\" y=\"\(size.height - y - h)\" width=\"\(w)\" height=\"\(h)\" \(fillAttr) \(strokeAttr)/>\n"

            case .ellipse(let cx, let cy, let rx, let ry):
                flushPath()
                let fillAttr = fillColor != .clear ? "fill=\"\(fillColor.toHex())\"" : "fill=\"none\""
                let strokeAttr = "stroke=\"\(strokeColor.toHex())\" stroke-width=\"\(strokeWidth)\""
                svg += "<ellipse cx=\"\(cx)\" cy=\"\(size.height - cy)\" rx=\"\(rx)\" ry=\"\(ry)\" \(fillAttr) \(strokeAttr)/>\n"

            case .arc:
                // Convert arc to path - simplified, would need proper implementation
                break

            case .text(let str, let x, let y, let style):
                flushPath()
                let escaped = escapeXML(str)
                let anchor = style.anchor.rawValue
                let fontWeight = style.fontWeight == .bold ? "font-weight=\"bold\"" : ""
                svg += "<text x=\"\(x)\" y=\"\(size.height - y)\" font-size=\"\(style.fontSize)\" \(fontWeight) text-anchor=\"\(anchor)\" fill=\"\(style.color.toHex())\">\(escaped)</text>\n"

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

            case .strokePath, .fillPath, .fillAndStrokePath:
                flushPath()

            default:
                break
            }
        }

        flushPath()

        svg += "</svg>"
        return svg
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
