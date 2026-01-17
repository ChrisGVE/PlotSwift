# ``PlotSwift``

A Swift vector graphics drawing library providing the foundation for data visualization.

## Overview

PlotSwift provides a retained-mode vector graphics system where all drawing operations are stored as commands. This architecture enables scale-free rendering and export to multiple formats (PNG, PDF, SVG) from the same drawing commands.

### Key Features

- **Retained-mode graphics**: Drawing commands are stored, not immediately rendered
- **Multiple export formats**: PNG, PDF, and SVG output
- **CoreGraphics-based**: Native rendering using Apple's graphics stack
- **Transform support**: Full 2D transformation stack (translate, scale, rotate)
- **Rich styling**: Colors, line styles, text styles, and transparency

### Getting Started

Create a ``DrawingContext``, add drawing commands, and export:

```swift
import PlotSwift

let ctx = DrawingContext()

// Draw a filled rectangle
ctx.setFillColor(.blue)
ctx.rect(50, 50, 200, 150)
ctx.fillPath()

// Export to PNG
let pngData = ctx.renderToPNG(size: CGSize(width: 400, height: 300))
```

## Topics

### Essentials

- <doc:Installation>
- <doc:QuickStart>

### Core Types

- ``Color``
- ``TextStyle``
- ``LineStyle``
- ``MarkerStyle``

### Drawing

- ``DrawingContext``
- ``DrawingCommand``
