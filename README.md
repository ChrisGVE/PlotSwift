# PlotSwift

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+-007AFF.svg?style=flat&logo=apple&logoColor=white)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)](https://opensource.org/licenses/MIT)
[![GitHub Release](https://img.shields.io/github/v/release/ChrisGVE/PlotSwift?style=flat&logo=github)](https://github.com/ChrisGVE/PlotSwift/releases)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue.svg?style=flat&logo=readthedocs&logoColor=white)](https://github.com/ChrisGVE/PlotSwift)

A Swift vector graphics drawing library providing the foundation for data visualization. PlotSwift uses a retained-mode command-based architecture for scale-free rendering, with export to PNG, PDF, and SVG formats.

## Overview

PlotSwift provides a low-level vector graphics system inspired by CoreGraphics but with a retained-mode architecture. All drawing operations are stored as commands that can be rendered at any resolution without quality loss.

### Design Philosophy

- **Vector-first rendering** - All drawing operations stored as commands for scale-free output
- **Multiple export formats** - PNG, PDF, and SVG from the same drawing commands
- **CoreGraphics based** - Native rendering using Apple's graphics stack
- **Foundation for plotting** - Building block for data visualization (high-level plotting APIs coming in future versions)

## Installation

### Swift Package Manager

Add PlotSwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisGVE/PlotSwift.git", from: "0.1.0")
]
```

Or add it directly in Xcode via File > Add Package Dependencies.

## Quick Start

### Basic Drawing

```swift
import PlotSwift

// Create a drawing context
let ctx = DrawingContext()

// Draw shapes
ctx.setFillColor(.blue)
ctx.rect(50, 50, 200, 150)
ctx.fillPath()

ctx.setStrokeColor(.red)
ctx.setStrokeWidth(2.0)
ctx.circle(cx: 150, cy: 125, r: 50)
ctx.strokePath()

// Add text
ctx.text("Hello PlotSwift", x: 150, y: 220, style: TextStyle(
    fontSize: 16,
    fontWeight: .bold,
    color: .black,
    anchor: .middle
))

// Export to PNG
if let pngData = ctx.renderToPNG(size: CGSize(width: 400, height: 300)) {
    // Use the PNG data
}
```

### Path Construction

```swift
let ctx = DrawingContext()

// Build a custom path
ctx.moveTo(100, 100)
ctx.lineTo(200, 100)
ctx.lineTo(200, 200)
ctx.lineTo(100, 200)
ctx.closePath()

ctx.setFillColor(Color(hex: "#3498db")!)
ctx.setStrokeColor(.black)
ctx.setStrokeWidth(2.0)
ctx.fillAndStrokePath()
```

### Curves and Arcs

```swift
let ctx = DrawingContext()

// Bezier curve
ctx.moveTo(50, 150)
ctx.curveTo(cp1x: 100, cp1y: 50, cp2x: 200, cp2y: 50, x: 250, y: 150)
ctx.setStrokeColor(.purple)
ctx.strokePath()

// Arc
ctx.arc(cx: 150, cy: 150, r: 80, startAngle: 0, endAngle: .pi * 1.5)
ctx.setStrokeColor(.orange)
ctx.setStrokeWidth(3.0)
ctx.strokePath()
```

### Transforms

```swift
let ctx = DrawingContext()

// Save state before transform
ctx.saveState()

// Apply transforms
ctx.translate(200, 200)
ctx.rotate(.pi / 4)  // 45 degrees
ctx.scale(1.5, 1.5)

// Draw at transformed position
ctx.rect(-25, -25, 50, 50)
ctx.setFillColor(.green)
ctx.fillPath()

// Restore original state
ctx.restoreState()
```

### Export Formats

```swift
let ctx = DrawingContext()
// ... add drawing commands ...

let size = CGSize(width: 800, height: 600)

// PNG with custom scale (for retina displays)
let pngData = ctx.renderToPNG(size: size, scale: 2.0)

// PDF (vector format)
let pdfData = ctx.renderToPDF(size: size)

// SVG (web-friendly vector)
let svgString = ctx.renderToSVG(size: size)
```

## API Reference

### Color

Create colors from RGB values, hex strings, or named colors:

```swift
let red = Color(red: 1, green: 0, blue: 0)
let blue = Color(hex: "#0000FF")!
let green = Color(name: "green")!

// Predefined colors
Color.black, Color.white, Color.red, Color.green, Color.blue
Color.yellow, Color.cyan, Color.magenta, Color.orange, Color.purple
Color.gray, Color.lightGray, Color.darkGray, Color.clear
```

### TextStyle

Configure text rendering:

```swift
let style = TextStyle(
    fontFamily: "sans-serif",
    fontSize: 14,
    fontWeight: .bold,    // .normal, .bold, .light
    color: .black,
    anchor: .middle       // .start, .middle, .end
)
```

### LineStyle

Available line styles:

```swift
LineStyle.solid     // Continuous line
LineStyle.dashed    // Long dashes
LineStyle.dotted    // Dots
LineStyle.dashDot   // Alternating dash-dot
LineStyle.none      // No line
```

### MarkerStyle

Marker shapes for data points (rendering support coming soon):

```swift
MarkerStyle.circle, .square, .diamond
MarkerStyle.triangleUp, .triangleDown, .triangleLeft, .triangleRight
MarkerStyle.plus, .cross, .star, .dot
```

### DrawingContext Methods

**Path Construction:**
- `moveTo(_ x:, _ y:)` - Start a new subpath
- `lineTo(_ x:, _ y:)` - Add line to current path
- `curveTo(cp1x:, cp1y:, cp2x:, cp2y:, x:, y:)` - Cubic Bezier curve
- `quadCurveTo(cpx:, cpy:, x:, y:)` - Quadratic Bezier curve
- `closePath()` - Close the current subpath

**Shapes:**
- `rect(_ x:, _ y:, _ width:, _ height:)` - Rectangle
- `ellipse(cx:, cy:, rx:, ry:)` - Ellipse
- `circle(cx:, cy:, r:)` - Circle (convenience)
- `arc(cx:, cy:, r:, startAngle:, endAngle:, clockwise:)` - Arc

**Text:**
- `text(_ string:, x:, y:, style:)` - Draw text

**Style State:**
- `setStrokeColor(_ color:)` - Set stroke color
- `setStrokeWidth(_ width:)` - Set line width
- `setStrokeStyle(_ style:)` - Set dash pattern
- `setFillColor(_ color:)` - Set fill color
- `setAlpha(_ alpha:)` - Set global alpha

**Drawing Operations:**
- `strokePath()` - Stroke the current path
- `fillPath()` - Fill the current path
- `fillAndStrokePath()` - Fill and stroke

**Transforms:**
- `translate(_ tx:, _ ty:)` - Translate coordinate system
- `scale(_ sx:, _ sy:)` - Scale coordinate system
- `rotate(_ angle:)` - Rotate (radians)
- `pushTransform(_ transform:)` - Push custom transform
- `popTransform()` - Pop transform

**State Management:**
- `saveState()` - Save graphics state
- `restoreState()` - Restore graphics state
- `clear()` - Clear all commands

**Export:**
- `renderToPNG(size:, scale:)` - Export to PNG data
- `renderToPDF(size:)` - Export to PDF data
- `renderToSVG(size:)` - Export to SVG string

## Roadmap

PlotSwift 0.1.0 provides the vector graphics foundation. Future versions will add:

- **0.2.x**: High-level plotting API (`plot()`, `scatter()`, Figure/Axes)
- **0.3.x**: Additional plot types (bar, histogram, box plot)
- **0.4.x**: Statistical visualizations, colormaps
- **0.5.x+**: Animation support (inspired by manim)

PlotSwift is designed to integrate with [NumericSwift](https://github.com/ChrisGVE/NumericSwift) and [ArraySwift](https://github.com/ChrisGVE/ArraySwift) for scientific computing workflows.

## Requirements

- Swift 5.9+
- iOS 15.0+ / macOS 12.0+
- Frameworks: CoreGraphics, CoreText, ImageIO

## License

PlotSwift is available under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.
