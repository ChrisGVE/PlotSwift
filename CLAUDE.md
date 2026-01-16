# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a specific test file
swift test --filter PlotSwiftTests

# Build for release
swift build -c release
```

## Project Overview

PlotSwift is a Swift library for data visualization, providing a vector graphics drawing system with export to PNG, PDF, and SVG formats. It is designed to work with NumericSwift and ArraySwift for scientific plotting.

### License

MIT License

### Design Philosophy

1. **Vector-first rendering** - All drawing operations are stored as commands for scale-free rendering
2. **Multiple export formats** - PNG, PDF, and SVG output
3. **CoreGraphics based** - Native rendering using Apple's graphics stack
4. **Matplotlib-inspired** - Familiar concepts for Python users

## Project Structure

```
Sources/PlotSwift/
└── PlotTypes.swift        # Core types: Color, TextStyle, DrawingContext, etc.

Tests/PlotSwiftTests/
└── PlotSwiftTests.swift   # Test suite
```

## Module API Reference

### Color (`PlotTypes.swift`)

```swift
// Create colors
let red = Color(red: 1, green: 0, blue: 0)
let blue = Color(hex: "#0000FF")
let green = Color(name: "green")

// Predefined colors
Color.black, Color.white, Color.red, Color.green, Color.blue
Color.yellow, Color.cyan, Color.magenta, Color.orange, Color.purple
Color.gray, Color.lightGray, Color.darkGray, Color.clear

// Properties
color.cgColor        // Core Graphics color
color.toHex()        // "#RRGGBB" string
```

### TextStyle

```swift
let style = TextStyle(
    fontFamily: "sans-serif",
    fontSize: 12,
    fontWeight: .bold,    // .normal, .bold, .light
    color: .black,
    anchor: .middle       // .start, .middle, .end
)
```

### LineStyle

```swift
LineStyle.solid     // "-"
LineStyle.dashed    // "--"
LineStyle.dotted    // ":"
LineStyle.dashDot   // "-."
LineStyle.none      // ""
```

### MarkerStyle

```swift
MarkerStyle.circle        // "o"
MarkerStyle.square        // "s"
MarkerStyle.diamond       // "D"
MarkerStyle.triangleUp    // "^"
MarkerStyle.triangleDown  // "v"
MarkerStyle.plus          // "+"
MarkerStyle.cross         // "x"
MarkerStyle.star          // "*"
MarkerStyle.dot           // "."
```

### DrawingContext

```swift
let ctx = DrawingContext()

// Path construction
ctx.moveTo(0, 0)
ctx.lineTo(100, 100)
ctx.curveTo(cp1x: 50, cp1y: 0, cp2x: 50, cp2y: 100, x: 100, y: 100)
ctx.closePath()

// Shapes
ctx.rect(10, 10, 80, 80)
ctx.ellipse(cx: 50, cy: 50, rx: 40, ry: 30)
ctx.circle(cx: 50, cy: 50, r: 25)
ctx.arc(cx: 50, cy: 50, r: 25, startAngle: 0, endAngle: .pi)

// Text
ctx.text("Hello", x: 10, y: 20, style: TextStyle())

// Style state
ctx.setStrokeColor(.blue)
ctx.setStrokeWidth(2.0)
ctx.setStrokeStyle(.dashed)
ctx.setFillColor(.red)
ctx.setAlpha(0.5)

// Drawing operations
ctx.strokePath()
ctx.fillPath()
ctx.fillAndStrokePath()

// Transforms
ctx.translate(10, 20)
ctx.scale(2, 2)
ctx.rotate(.pi / 4)
ctx.pushTransform(transform)
ctx.popTransform()

// State management
ctx.saveState()
ctx.restoreState()

// Export
let pngData = ctx.renderToPNG(size: CGSize(width: 800, height: 600))
let pdfData = ctx.renderToPDF(size: CGSize(width: 800, height: 600))
let svgString = ctx.renderToSVG(size: CGSize(width: 800, height: 600))
```

### DrawingCommand

Low-level drawing commands stored by DrawingContext:

```swift
public enum DrawingCommand {
    // Path construction
    case moveTo(x: Double, y: Double)
    case lineTo(x: Double, y: Double)
    case curveTo(...)
    case closePath

    // Shapes
    case rect(x: Double, y: Double, width: Double, height: Double)
    case ellipse(cx: Double, cy: Double, rx: Double, ry: Double)
    case arc(...)

    // Text
    case text(String, x: Double, y: Double, style: TextStyle)

    // Style state
    case setStrokeColor(Color)
    case setStrokeWidth(Double)
    case setFillColor(Color)
    // ...

    // Drawing operations
    case strokePath
    case fillPath
    case fillAndStrokePath
}
```

## Integration with Sister Libraries

PlotSwift is part of a suite of Swift scientific computing libraries:

- **NumericSwift** - Scientific computing (distributions, integration, optimization, etc.)
- **ArraySwift** - N-dimensional arrays

Future integration will allow:
```swift
import PlotSwift
import NumericSwift

// Plot data from NumericSwift calculations
let x = Array(stride(from: 0, through: 2 * .pi, by: 0.1))
let y = x.map { sin($0) }
// plot(x, y)  // Future API
```

## Development Guidelines

1. **Matplotlib familiarity** - Study matplotlib for API design patterns
2. **Test coverage** - Every function needs comprehensive tests
3. **Documentation** - DocC comments on all public functions
4. **Performance** - Optimize rendering for large datasets
5. **Cross-platform** - Support both macOS and iOS

## Release Preparation Tasks

### Task 1: Create Comprehensive README.md

Create a professional README with:
- Badges (Swift version, platforms, SPM compatible, license, GitHub release, documentation)
- Overview and design philosophy
- Installation instructions (SPM)
- Quick start examples (create context, draw shapes, export)
- API overview
- Requirements section
- License section

Badge format to use:
```markdown
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)](https://opensource.org/licenses/MIT)
[![GitHub Release](https://img.shields.io/github/v/release/ChrisGVE/PlotSwift?style=flat&logo=github)](https://github.com/ChrisGVE/PlotSwift/releases)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue.svg?style=flat&logo=readthedocs&logoColor=white)](https://github.com/ChrisGVE/PlotSwift)
```

### Task 2: Create DocC Documentation Catalog

Create directory structure:
```
Sources/PlotSwift/PlotSwift.docc/
├── Documentation.md          # Landing page
├── Articles/
│   ├── Installation.md
│   └── QuickStart.md
└── Modules/
    ├── Color.md
    ├── TextStyle.md
    ├── LineStyle.md
    ├── MarkerStyle.md
    ├── DrawingContext.md
    └── Export.md
```

Add swift-docc-plugin to Package.swift:
```swift
.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
```

### Task 3: Ensure Source Files Have DocC Comments

Review and add DocC comments to all public APIs in:
- PlotTypes.swift (Color, TextStyle, LineStyle, MarkerStyle, DrawingCommand, DrawingContext)

### Task 4: Test Coverage Audit

- Run `swift test` and verify all tests pass
- Review test coverage for:
  - Color creation (RGB, hex, named)
  - DrawingContext operations
  - Export formats (PNG, PDF, SVG)
- Add tests for any untested functionality

### Task 5: Create CHANGELOG.md

Create CHANGELOG.md following Keep a Changelog format:
```markdown
# Changelog

All notable changes to PlotSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - YYYY-MM-DD

### Added
- `Color` type with RGB, hex, and named color support
- `TextStyle` for text rendering configuration
- `LineStyle` enum (solid, dashed, dotted, dash-dot)
- `MarkerStyle` enum for scatter plot markers
- `DrawingCommand` enum for vector graphics operations
- `DrawingContext` for retained-mode vector graphics
- PNG export via CoreGraphics
- PDF export via CoreGraphics
- SVG export via string generation

### Dependencies
- Requires Swift 5.9+, iOS 15+ / macOS 12+
- Uses CoreGraphics, CoreText, ImageIO frameworks
```

### Task 6: Final Review and Release

1. Verify no compiler warnings: `swift build 2>&1 | grep -i warning`
2. Verify DocC generates: `swift package generate-documentation --target PlotSwift`
3. Push all changes to GitHub
4. Create release tag: `git tag 0.1.0 && git push origin 0.1.0`
5. Create GitHub release with release notes

## Test Statistics

- **Total tests**: TBD (audit needed)
- **Known failures**: TBD
