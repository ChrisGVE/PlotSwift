//
//  Color.swift
//  PlotSwift
//
//  A color representation for plotting and drawing operations.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics
import Foundation

// MARK: - Color

/// A color representation for plotting and drawing operations.
///
/// Create colors from RGB values, hex strings, or named colors:
///
/// ```swift
/// // RGB values (0.0 to 1.0)
/// let red = Color(red: 1, green: 0, blue: 0)
///
/// // Hex string
/// let blue = Color(hex: "#0000FF")!
///
/// // Named color
/// let green = Color(name: "green")!
///
/// // Predefined colors
/// let black = Color.black
/// ```
public struct Color: Equatable, Sendable {
  /// The red component (0.0 to 1.0).
  public let red: Double
  /// The green component (0.0 to 1.0).
  public let green: Double
  /// The blue component (0.0 to 1.0).
  public let blue: Double
  /// The alpha (opacity) component (0.0 to 1.0).
  public let alpha: Double

  /// Creates a color from RGB components.
  /// - Parameters:
  ///   - red: Red component (0.0 to 1.0)
  ///   - green: Green component (0.0 to 1.0)
  ///   - blue: Blue component (0.0 to 1.0)
  ///   - alpha: Alpha (opacity) component (0.0 to 1.0), defaults to 1.0
  public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
    self.red = min(max(red, 0), 1)
    self.green = min(max(green, 0), 1)
    self.blue = min(max(blue, 0), 1)
    self.alpha = min(max(alpha, 0), 1)
  }

  /// Creates a color from a hex string.
  ///
  /// Supports 6-digit (`"#RRGGBB"` or `"RRGGBB"`) and 8-digit (`"#RRGGBBAA"`) formats.
  ///
  /// - Parameter hex: The hex color string
  /// - Returns: A Color if the string is valid, nil otherwise
  public init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

    if hexSanitized.count == 6 {
      self.init(
        red: Double((rgb & 0xFF0000) >> 16) / 255.0,
        green: Double((rgb & 0x00FF00) >> 8) / 255.0,
        blue: Double(rgb & 0x0000FF) / 255.0
      )
    } else if hexSanitized.count == 8 {
      self.init(
        red: Double((rgb & 0xFF00_0000) >> 24) / 255.0,
        green: Double((rgb & 0x00FF_0000) >> 16) / 255.0,
        blue: Double((rgb & 0x0000_FF00) >> 8) / 255.0,
        alpha: Double(rgb & 0x0000_00FF) / 255.0
      )
    } else {
      return nil
    }
  }

  /// Creates a color from a named color string.
  ///
  /// Supported names: black, white, red, green, blue, yellow, cyan, magenta,
  /// orange, purple, brown, pink, gray/grey, lightgray/lightgrey, darkgray/darkgrey,
  /// none/transparent.
  ///
  /// - Parameter name: The color name (case-insensitive)
  /// - Returns: A Color if the name is recognized, nil otherwise
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

  /// Returns the color as a CoreGraphics CGColor.
  public var cgColor: CGColor {
    CGColor(red: red, green: green, blue: blue, alpha: alpha)
  }

  /// Converts the color to a hex string.
  /// - Parameter includeAlpha: If true, includes alpha as the last two digits
  /// - Returns: A hex string in format "#RRGGBB" or "#RRGGBBAA"
  public func toHex(includeAlpha: Bool = false) -> String {
    let r = Int(min(max(red, 0), 1) * 255)
    let g = Int(min(max(green, 0), 1) * 255)
    let b = Int(min(max(blue, 0), 1) * 255)
    if includeAlpha {
      let a = Int(min(max(alpha, 0), 1) * 255)
      return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
    return String(format: "#%02X%02X%02X", r, g, b)
  }

  /// Returns this color with a different alpha value.
  public func withAlpha(_ alpha: Double) -> Color {
    Color(red: red, green: green, blue: blue, alpha: alpha)
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
