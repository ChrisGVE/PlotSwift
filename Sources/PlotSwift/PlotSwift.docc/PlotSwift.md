# ``PlotSwift``

A Swift library for data visualization with a high-level Figure/Axes API and vector-first rendering.

## Overview

PlotSwift provides two complementary layers for producing plots.

The **high-level layer** mirrors matplotlib's object model: create a ``Figure``,
add one or more ``Axes`` via ``Figure/addAxes(rect:)`` or
``Figure/addSubplot(rows:cols:index:)``, call methods such as
``Axes/plot(_:_:color:lineStyle:lineWidth:marker:markerSize:label:)``,
``Axes/scatter(_:_:color:marker:markerSize:alpha:label:)``,
``Axes/bar(_:_:width:bottom:color:edgeColor:edgeWidth:label:)``, or
``Axes/hist(_:bins:range:density:cumulative:color:edgeColor:alpha:label:)``,
and export the result with a single call.

The **low-level layer** gives direct access to ``DrawingContext`` for building
arbitrary vector graphics with paths, shapes, text, and transforms.

Both layers share the same export pipeline: PNG, PDF, and SVG are all produced
from the same retained command list, so a drawing is defined once and rendered at
any size or format.

```swift
import PlotSwift

let fig = Figure(width: 800, height: 600)
let ax  = fig.addAxes()

let x = stride(from: 0.0, through: .pi * 2, by: 0.1).map { $0 }
ax.plot(x, x.map { sin($0) }, label: "sin(x)")
ax.plot(x, x.map { cos($0) }, label: "cos(x)", lineStyle: .dashed)
ax.setTitle("Trigonometric Functions")
ax.setXLabel("x")
ax.setYLabel("y")
ax.legend()
ax.grid(true)

let png = fig.renderToPNG()
```

### Supported Platforms

PlotSwift requires Swift 5.9+ and supports:

- iOS 15.0 and later
- macOS 12.0 and later
- visionOS 1.0 and later
- watchOS 8.0 and later
- tvOS 15.0 and later

All rendering uses CoreGraphics and CoreText; no third-party dependencies are
required at runtime.

## Topics

### Essentials

- <doc:GettingStarted>
- ``Figure``
- ``Axes``
- ``Color``

### Plot Types

- ``DataSeries``
- ``BarSeries``
- ``HistogramBins``
- ``SeriesType``

### Styling

- ``TextStyle``
- ``LineStyle``
- ``MarkerStyle``
- ``ColorPalette``

### Drawing

- <doc:PlottingGuide>
- ``DrawingContext``
- ``DrawingCommand``

### Geometry

- ``DataRange``
- ``CoordinateTransform``
- ``PlotArea``

### Annotations

- <doc:ExportFormats>
- ``Annotation``
- ``ArrowProps``
- ``ArrowStyle``
- ``ReferenceLine``
- ``ReferenceSpan``
- ``FillBetween``
- ``ErrorBarValue``
