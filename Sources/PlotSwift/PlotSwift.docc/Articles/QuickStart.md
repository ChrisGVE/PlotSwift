# Quick Start

Learn the basics of drawing with PlotSwift.

## Overview

PlotSwift uses a retained-mode architecture where you create a ``DrawingContext``, add drawing commands, and then render to your desired output format.

## Basic Drawing

Create a context and draw shapes:

```swift
import PlotSwift

let ctx = DrawingContext()

// Set fill color and draw a rectangle
ctx.setFillColor(.blue)
ctx.rect(50, 50, 200, 150)
ctx.fillPath()

// Set stroke color and draw a circle
ctx.setStrokeColor(.red)
ctx.setStrokeWidth(2.0)
ctx.circle(cx: 150, cy: 125, r: 50)
ctx.strokePath()
```

## Working with Colors

Create colors from RGB values, hex strings, or named colors:

```swift
// RGB
let customRed = Color(red: 1, green: 0, blue: 0)

// Hex string
let oceanBlue = Color(hex: "#3498db")!

// Named color
let forestGreen = Color(name: "green")!

// Predefined colors
let black = Color.black
let white = Color.white
```

## Path Construction

Build custom paths with lines and curves:

```swift
let ctx = DrawingContext()

// Start a path
ctx.moveTo(100, 100)
ctx.lineTo(200, 100)
ctx.lineTo(150, 200)
ctx.closePath()

// Fill the triangle
ctx.setFillColor(.orange)
ctx.fillPath()
```

## Bezier Curves

Draw smooth curves:

```swift
// Cubic Bezier curve
ctx.moveTo(50, 150)
ctx.curveTo(cp1x: 100, cp1y: 50, cp2x: 200, cp2y: 50, x: 250, y: 150)
ctx.setStrokeColor(.purple)
ctx.strokePath()

// Quadratic Bezier curve
ctx.moveTo(50, 250)
ctx.quadCurveTo(cpx: 150, cpy: 150, x: 250, y: 250)
ctx.strokePath()
```

## Adding Text

Draw text with custom styling:

```swift
let style = TextStyle(
    fontSize: 24,
    fontWeight: .bold,
    color: .black,
    anchor: .middle
)

ctx.text("Hello PlotSwift", x: 200, y: 50, style: style)
```

## Transforms

Apply transformations to create complex drawings:

```swift
// Save the current state
ctx.saveState()

// Apply transforms
ctx.translate(200, 200)
ctx.rotate(.pi / 4)  // 45 degrees
ctx.scale(2.0, 2.0)

// Draw at the transformed position
ctx.rect(-25, -25, 50, 50)
ctx.setFillColor(.green)
ctx.fillPath()

// Restore the original state
ctx.restoreState()
```

## Exporting

Export your drawing to different formats:

```swift
let size = CGSize(width: 800, height: 600)

// PNG (raster)
if let pngData = ctx.renderToPNG(size: size, scale: 2.0) {
    // Save or use the PNG data
}

// PDF (vector)
if let pdfData = ctx.renderToPDF(size: size) {
    // Save or use the PDF data
}

// SVG (web-friendly vector)
let svgString = ctx.renderToSVG(size: size)
```

## Complete Example

Here's a complete example that draws a simple chart:

```swift
import PlotSwift
import Foundation

let ctx = DrawingContext()

// Background
ctx.setFillColor(Color(hex: "#f5f5f5")!)
ctx.rect(0, 0, 400, 300)
ctx.fillPath()

// Draw bars
let data = [120.0, 180.0, 90.0, 150.0, 200.0]
let colors: [Color] = [.red, .blue, .green, .orange, .purple]
let barWidth = 50.0
let spacing = 20.0

for (i, value) in data.enumerated() {
    let x = 40 + Double(i) * (barWidth + spacing)
    ctx.setFillColor(colors[i])
    ctx.rect(x, 250 - value, barWidth, value)
    ctx.fillPath()
}

// Title
ctx.text("Sample Data", x: 200, y: 280, style: TextStyle(
    fontSize: 18,
    fontWeight: .bold,
    color: .black,
    anchor: .middle
))

// Export
let png = ctx.renderToPNG(size: CGSize(width: 400, height: 300))
```
