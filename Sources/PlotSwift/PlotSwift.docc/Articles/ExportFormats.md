# Export Formats

Render a figure or drawing context to PNG, PDF, or SVG.

## Overview

PlotSwift uses a retained command list: all drawing operations are recorded as
``DrawingCommand`` values rather than executed immediately. When you call an export
method, the command list is replayed against the target renderer. This means the
same drawing can be exported to multiple formats without repeating any drawing
code.

Both ``Figure`` and ``DrawingContext`` expose the same three export methods.

## PNG

PNG output is raster: the drawing is rendered into a bitmap at a fixed pixel size.
Supply a `scale` factor greater than 1.0 to produce a high-resolution image
suitable for Retina displays or print.

### From Figure

```swift
let fig = Figure(width: 800, height: 600)
// … add axes and data …

// 1× resolution (800 × 600 px)
let png1x = fig.renderToPNG()

// 2× resolution (1600 × 1200 px), same logical size
let png2x = fig.renderToPNG(scale: 2.0)
```

### From DrawingContext

```swift
let ctx = DrawingContext()
// … drawing commands …

let size = CGSize(width: 400, height: 300)
let pngData = ctx.renderToPNG(size: size, scale: 2.0)
```

`renderToPNG` returns `Data?`. It returns `nil` only when CoreGraphics cannot
allocate the bitmap context, which is rare in practice.

### Limitations

- Text rendering quality at small sizes depends on the system font rasterizer.
- Very large bitmaps (scale > 4.0 on large figures) may exhaust available memory.
- PNG output does not embed color-profile information.

## PDF

PDF output is vector and resolution-independent. The resulting data encodes all
paths, text, and transforms using CoreGraphics PDF primitives.

### From Figure

```swift
let pdfData = fig.renderToPDF()
```

### From DrawingContext

```swift
let pdfData = ctx.renderToPDF(size: CGSize(width: 800, height: 600))
```

`renderToPDF` returns `Data?`. It returns `nil` only when the underlying
CGDataConsumer or CGContext cannot be created.

### Limitations

- SVG-specific features such as `viewBox` scaling do not apply to PDF output.
- Fonts are embedded as paths; custom font families that are not installed on the
  rendering host fall back to the system default.

## SVG

SVG output is a UTF-8 string containing a complete `<svg>` document. It is
resolution-independent and can be embedded directly in HTML or opened in any
vector graphics application.

### From Figure

```swift
let svgString = fig.renderToSVG()
```

### From DrawingContext

```swift
let svgString = ctx.renderToSVG(size: CGSize(width: 800, height: 600))
```

`renderToSVG` always returns a non-empty `String`.

### Limitations

- Bezier curves and ellipses are translated to SVG `<path>` elements; very
  complex paths may produce large SVG files.
- Text is emitted as `<text>` elements with a `font-family` attribute derived
  from ``TextStyle/fontFamily``. Rendering depends on the viewer's available
  fonts.
- Clip regions are not yet supported in the SVG renderer; clipping applied via
  ``DrawingContext`` state is silently ignored in SVG output.
- The `<svg>` element uses a fixed `viewBox` matching the supplied `size`
  parameter; responsive scaling via CSS must be applied by the caller.

## Choosing a Format

| Requirement | Recommended format |
|-------------|--------------------|
| Web embedding | SVG |
| Print or archival | PDF |
| Screen display at fixed size | PNG (scale 2.0 for Retina) |
| Pixel-perfect bitmap for ImageView/UIImageView | PNG |
| Programmatic editing after export | SVG or PDF |

## Saving to Disk

```swift
import Foundation

// PNG
if let png = fig.renderToPNG(scale: 2.0) {
    let url = URL(fileURLWithPath: "/tmp/chart.png")
    try png.write(to: url)
}

// PDF
if let pdf = fig.renderToPDF() {
    let url = URL(fileURLWithPath: "/tmp/chart.pdf")
    try pdf.write(to: url)
}

// SVG
let svg = fig.renderToSVG()
let url = URL(fileURLWithPath: "/tmp/chart.svg")
try svg.write(to: url, atomically: true, encoding: .utf8)
```
