//
//  ColorPalette.swift
//  PlotSwift
//
//  Color palettes and automatic series color cycling.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - ColorPalette

/// A named collection of colors used for data series coloring and continuous
/// color mapping.
///
/// Use categorical palettes (``tab10``, ``set1``, etc.) to assign distinct colors
/// to discrete series, or sequential/diverging palettes (``viridis``, ``plasma``,
/// ``coolwarm``, etc.) to map scalar values to color via ``color(at:)``.
///
/// ```swift
/// // Categorical: pick colors by index
/// let palette = ColorPalette.tab10
/// let firstColor = palette.colors[0]
///
/// // Continuous: interpolate by position
/// let mid = ColorPalette.viridis.color(at: 0.5)
/// ```
public struct ColorPalette: Sendable {

  // MARK: Public properties

  /// The ordered list of key colors that define this palette.
  public let colors: [Color]

  /// A human-readable identifier for this palette.
  public let name: String

  // MARK: Initialiser

  /// Creates a palette with the given name and key colors.
  /// - Parameters:
  ///   - name: A human-readable identifier.
  ///   - colors: Key colors; must not be empty.
  public init(name: String, colors: [Color]) {
    precondition(!colors.isEmpty, "A ColorPalette must contain at least one color.")
    self.name = name
    self.colors = colors
  }

  // MARK: Continuous interpolation

  /// Returns a color interpolated between the palette's key stops.
  ///
  /// - Parameter t: Position in `[0, 1]`; clamped automatically.
  /// - Returns: The linearly-interpolated color at position `t`.
  public func color(at t: Double) -> Color {
    let t = min(max(t, 0), 1)
    guard colors.count > 1 else { return colors[0] }
    let scaled = t * Double(colors.count - 1)
    let lo = Int(scaled)
    let hi = min(lo + 1, colors.count - 1)
    let frac = scaled - Double(lo)
    return lerp(colors[lo], colors[hi], frac)
  }

  // MARK: Palette lookup

  /// Returns a predefined palette matching the given name (case-insensitive).
  ///
  /// Recognised names: `tab10`, `set1`, `set2`, `set3`,
  /// `viridis`, `plasma`, `magma`, `inferno`, `coolwarm`.
  ///
  /// - Parameter name: The palette identifier.
  /// - Returns: A matching palette, or `nil` if not found.
  public static func named(_ name: String) -> ColorPalette? {
    switch name.lowercased() {
    case "tab10": return .tab10
    case "set1": return .set1
    case "set2": return .set2
    case "set3": return .set3
    case "viridis": return .viridis
    case "plasma": return .plasma
    case "magma": return .magma
    case "inferno": return .inferno
    case "coolwarm": return .coolwarm
    default: return nil
    }
  }

  // MARK: - Private helpers

  private func lerp(_ a: Color, _ b: Color, _ t: Double) -> Color {
    Color(
      red: a.red + (b.red - a.red) * t,
      green: a.green + (b.green - a.green) * t,
      blue: a.blue + (b.blue - a.blue) * t,
      alpha: a.alpha + (b.alpha - a.alpha) * t
    )
  }
}

// MARK: - Categorical palettes

extension ColorPalette {

  // swiftlint:disable line_length

  /// Matplotlib's default 10-color categorical palette (exact hex values from
  /// matplotlib 3.x `tab10`).
  public static let tab10 = ColorPalette(
    name: "tab10",
    colors: [
      Color(hex: "#1f77b4")!, Color(hex: "#ff7f0e")!, Color(hex: "#2ca02c")!,
      Color(hex: "#d62728")!, Color(hex: "#9467bd")!, Color(hex: "#8c564b")!,
      Color(hex: "#e377c2")!, Color(hex: "#7f7f7f")!, Color(hex: "#bcbd22")!,
      Color(hex: "#17becf")!,
    ])

  /// ColorBrewer Set1 – 9 bold qualitative colors.
  public static let set1 = ColorPalette(
    name: "set1",
    colors: [
      Color(hex: "#e41a1c")!, Color(hex: "#377eb8")!, Color(hex: "#4daf4a")!,
      Color(hex: "#984ea3")!, Color(hex: "#ff7f00")!, Color(hex: "#ffff33")!,
      Color(hex: "#a65628")!, Color(hex: "#f781bf")!, Color(hex: "#999999")!,
    ])

  /// ColorBrewer Set2 – 8 softer qualitative colors.
  public static let set2 = ColorPalette(
    name: "set2",
    colors: [
      Color(hex: "#66c2a5")!, Color(hex: "#fc8d62")!, Color(hex: "#8da0cb")!,
      Color(hex: "#e78ac3")!, Color(hex: "#a6d854")!, Color(hex: "#ffd92f")!,
      Color(hex: "#e5c494")!, Color(hex: "#b3b3b3")!,
    ])

  /// ColorBrewer Set3 – 12 light qualitative colors.
  public static let set3 = ColorPalette(
    name: "set3",
    colors: [
      Color(hex: "#8dd3c7")!, Color(hex: "#ffffb3")!, Color(hex: "#bebada")!,
      Color(hex: "#fb8072")!, Color(hex: "#80b1d3")!, Color(hex: "#fdb462")!,
      Color(hex: "#b3de69")!, Color(hex: "#fccde5")!, Color(hex: "#d9d9d9")!,
      Color(hex: "#bc80bd")!, Color(hex: "#ccebc5")!, Color(hex: "#ffed6f")!,
    ])

  // swiftlint:enable line_length
}

// MARK: - Sequential / diverging palettes

extension ColorPalette {

  /// Viridis perceptually-uniform sequential palette (~16 key stops).
  public static let viridis = ColorPalette(
    name: "viridis",
    colors: [
      Color(hex: "#440154")!, Color(hex: "#48186a")!, Color(hex: "#472d7b")!,
      Color(hex: "#424086")!, Color(hex: "#3b528b")!, Color(hex: "#33638d")!,
      Color(hex: "#2c728e")!, Color(hex: "#26828e")!, Color(hex: "#21918c")!,
      Color(hex: "#1fa088")!, Color(hex: "#28ae80")!, Color(hex: "#3fbc73")!,
      Color(hex: "#5ec962")!, Color(hex: "#84d44b")!, Color(hex: "#addc30")!,
      Color(hex: "#fde725")!,
    ])

  /// Plasma perceptually-uniform sequential palette (~16 key stops).
  public static let plasma = ColorPalette(
    name: "plasma",
    colors: [
      Color(hex: "#0d0887")!, Color(hex: "#3a049a")!, Color(hex: "#5c01a6")!,
      Color(hex: "#7e03a8")!, Color(hex: "#9c179e")!, Color(hex: "#b52f8c")!,
      Color(hex: "#cc4778")!, Color(hex: "#de6065")!, Color(hex: "#ed7953")!,
      Color(hex: "#f89540")!, Color(hex: "#fdb42f")!, Color(hex: "#fbd124")!,
      Color(hex: "#f5e626")!, Color(hex: "#eff821")!, Color(hex: "#f0f921")!,
      Color(hex: "#f0f921")!,
    ])

  /// Magma perceptually-uniform sequential palette (~16 key stops).
  public static let magma = ColorPalette(
    name: "magma",
    colors: [
      Color(hex: "#000004")!, Color(hex: "#0c0926")!, Color(hex: "#221150")!,
      Color(hex: "#400f74")!, Color(hex: "#5f187f")!, Color(hex: "#7b2382")!,
      Color(hex: "#982d80")!, Color(hex: "#b63679")!, Color(hex: "#d3436e")!,
      Color(hex: "#e95462")!, Color(hex: "#f1605d")!, Color(hex: "#f8765c")!,
      Color(hex: "#fe9f6d")!, Color(hex: "#fecb90")!, Color(hex: "#fde2c3")!,
      Color(hex: "#fcfdbf")!,
    ])

  /// Inferno perceptually-uniform sequential palette (~16 key stops).
  public static let inferno = ColorPalette(
    name: "inferno",
    colors: [
      Color(hex: "#000004")!, Color(hex: "#0d0829")!, Color(hex: "#210c4a")!,
      Color(hex: "#3b0f70")!, Color(hex: "#56157f")!, Color(hex: "#721f81")!,
      Color(hex: "#8c2981")!, Color(hex: "#a8327d")!, Color(hex: "#c43c75")!,
      Color(hex: "#da4e6b")!, Color(hex: "#ed6657")!, Color(hex: "#f7814e")!,
      Color(hex: "#fca050")!, Color(hex: "#fec372")!, Color(hex: "#fee49c")!,
      Color(hex: "#fcffa4")!,
    ])

  /// Coolwarm diverging palette (blue → white → red, ~16 key stops).
  public static let coolwarm = ColorPalette(
    name: "coolwarm",
    colors: [
      Color(hex: "#3b4cc0")!, Color(hex: "#5977d8")!, Color(hex: "#7b9ff9")!,
      Color(hex: "#9fbfff")!, Color(hex: "#bcd4f6")!, Color(hex: "#d9e8f5")!,
      Color(hex: "#ead4c8")!, Color(hex: "#f7b89c")!, Color(hex: "#f49577")!,
      Color(hex: "#e8705a")!, Color(hex: "#d44e45")!, Color(hex: "#b40426")!,
      Color(hex: "#c03232")!, Color(hex: "#cc4040")!, Color(hex: "#d45050")!,
      Color(hex: "#b40426")!,
    ])
}

// MARK: - ColorCycle

/// Iterates through a palette's colors in order, wrapping automatically.
///
/// Use `ColorCycle` to assign distinct colors to successive data series without
/// managing indices manually:
///
/// ```swift
/// let cycle = ColorCycle(palette: .tab10)
/// let c1 = cycle.next()   // tab10[0]
/// let c2 = cycle.next()   // tab10[1]
/// cycle.reset()
/// let c3 = cycle.next()   // tab10[0] again
/// ```
public final class ColorCycle: @unchecked Sendable {

  // MARK: Public properties

  /// The palette this cycle draws from.
  public let palette: ColorPalette

  /// The index of the next color that will be returned by ``next()``.
  public private(set) var currentIndex: Int = 0

  // MARK: Initialiser

  /// Creates a new cycle over the given palette.
  /// - Parameter palette: Defaults to ``ColorPalette/tab10``.
  public init(palette: ColorPalette = .tab10) {
    self.palette = palette
  }

  // MARK: Public interface

  /// Returns the next color in the palette, wrapping around after the last.
  public func next() -> Color {
    let color = palette.colors[currentIndex % palette.colors.count]
    currentIndex += 1
    return color
  }

  /// Resets the cycle back to the first color in the palette.
  public func reset() {
    currentIndex = 0
  }
}
