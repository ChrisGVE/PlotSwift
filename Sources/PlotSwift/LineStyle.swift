//
//  LineStyle.swift
//  PlotSwift
//
//  Dash pattern style for stroked lines.
//
//  Copyright (c) 2026 Christian C. Berclaz. All rights reserved.
//  Licensed under the MIT License.
//

import CoreGraphics

// MARK: - LineStyle

/// Dash pattern style for stroked lines.
///
/// LineStyle defines the dash pattern used when stroking paths:
///
/// ```swift
/// ctx.setStrokeStyle(.dashed)
/// ctx.moveTo(0, 50)
/// ctx.lineTo(200, 50)
/// ctx.strokePath()
/// ```
public enum LineStyle: String, Sendable {
  /// A continuous solid line.
  case solid = "-"
  /// A dashed line pattern.
  case dashed = "--"
  /// A dotted line pattern.
  case dotted = ":"
  /// An alternating dash-dot pattern.
  case dashDot = "-."
  /// No line (invisible).
  case none = ""

  /// The CoreGraphics dash pattern array for this style.
  public var dashPattern: [CGFloat]? {
    switch self {
    case .solid, .none: return nil
    case .dashed: return [6, 4]
    case .dotted: return [2, 2]
    case .dashDot: return [6, 2, 2, 2]
    }
  }
}
