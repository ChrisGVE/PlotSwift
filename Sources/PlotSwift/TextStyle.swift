//
//  TextStyle.swift
//  PlotSwift
//
//  Configuration for text rendering appearance.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

// MARK: - TextStyle

/// Configuration for text rendering appearance.
///
/// Use TextStyle to customize how text is displayed:
///
/// ```swift
/// let style = TextStyle(
///     fontSize: 16,
///     fontWeight: .bold,
///     color: .black,
///     anchor: .middle
/// )
/// ctx.text("Hello", x: 100, y: 50, style: style)
/// ```
public struct TextStyle: Equatable, Sendable {
  /// The font family name.
  public var fontFamily: String
  /// The font size in points.
  public var fontSize: Double
  /// The font weight (normal, bold, or light).
  public var fontWeight: FontWeight
  /// The text color.
  public var color: Color
  /// The text anchor point for positioning.
  public var anchor: TextAnchor

  /// Font weight options.
  public enum FontWeight: String, Sendable {
    /// Normal weight.
    case normal = "normal"
    /// Bold weight.
    case bold = "bold"
    /// Light weight.
    case light = "light"
  }

  /// Text anchor position for alignment.
  public enum TextAnchor: String, Sendable {
    /// Anchor at the start (left for LTR text).
    case start = "start"
    /// Anchor at the middle (center aligned).
    case middle = "middle"
    /// Anchor at the end (right for LTR text).
    case end = "end"
  }

  /// Creates a text style with the specified properties.
  /// - Parameters:
  ///   - fontFamily: The font family name (default: "sans-serif")
  ///   - fontSize: The font size in points (default: 12)
  ///   - fontWeight: The font weight (default: .normal)
  ///   - color: The text color (default: .black)
  ///   - anchor: The text anchor for positioning (default: .start)
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
