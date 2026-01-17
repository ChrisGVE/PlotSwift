# Changelog

All notable changes to PlotSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-17

### Added

- **Color type** with multiple initialization options:
  - RGB/RGBA constructors with values 0-1
  - Hex string parsing (with/without `#`, 6 and 8 digit formats)
  - Named color parsing (case insensitive, gray/grey variants)
  - 14 predefined static colors (black, white, red, green, blue, yellow, cyan, magenta, orange, purple, gray, lightGray, darkGray, clear)
  - `toHex()` conversion with optional alpha output
  - `cgColor` property for CoreGraphics integration

- **TextStyle** for text rendering configuration:
  - Font family, size, and weight (normal, bold, light)
  - Text color
  - Text anchor alignment (start, middle, end)

- **LineStyle** enum for stroke patterns:
  - Solid (`-`), dashed (`--`), dotted (`:`), dash-dot (`-.`), none

- **MarkerStyle** enum for scatter plot markers:
  - Circle, square, diamond, triangles (up/down), plus, cross, star, dot

- **DrawingCommand** enum for vector graphics operations:
  - Path commands: moveTo, lineTo, curveTo, quadCurveTo, closePath
  - Shape commands: rect, ellipse, arc
  - Text rendering with style
  - Style commands: setStrokeColor, setStrokeWidth, setFillColor, setAlpha
  - Drawing operations: strokePath, fillPath, fillAndStrokePath
  - Transform commands: translate, scale, rotate, pushTransform, popTransform
  - State management: saveState, restoreState
  - Clipping: clip

- **DrawingContext** retained-mode vector graphics system:
  - All drawing operations stored as commands for scale-free rendering
  - Full 2D transformation stack support
  - State stack for save/restore operations
  - Bounds computation for drawn content
  - Three export formats:
    - PNG (raster) via CoreGraphics with configurable scale
    - PDF (vector) via CoreGraphics
    - SVG (vector) via string generation

- **Documentation**:
  - Comprehensive DocC documentation catalog
  - Quick start guide with examples
  - Installation instructions

### Dependencies

- Swift 5.9+
- iOS 15.0+ / macOS 12.0+
- Apple frameworks: CoreGraphics, CoreText, ImageIO (included in platforms)

[0.1.0]: https://github.com/ChrisGVE/PlotSwift/releases/tag/0.1.0
