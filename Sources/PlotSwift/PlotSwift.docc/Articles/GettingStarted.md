# Getting Started

Add PlotSwift to your project and produce your first plot.

## Overview

PlotSwift is distributed via Swift Package Manager. Once installed, the typical
workflow is: create a ``Figure``, configure one or more ``Axes``, add data series,
and export to PNG, PDF, or SVG.

## Installation

### Package.swift

Add PlotSwift to the `dependencies` array in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisGVE/PlotSwift.git", from: "0.1.0")
]
```

Then declare the dependency on your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["PlotSwift"]
)
```

### Xcode

1. Open your project in Xcode.
2. Choose **File > Add Package Dependencies**.
3. Enter `https://github.com/ChrisGVE/PlotSwift.git` and choose a version.
4. Add **PlotSwift** to the target you want to use it from.

### Requirements

| Platform   | Minimum version |
|------------|-----------------|
| iOS        | 15.0            |
| macOS      | 12.0            |
| visionOS   | 1.0             |
| watchOS    | 8.0             |
| tvOS       | 15.0            |

Swift 5.9 or later is required. No additional runtime frameworks are needed beyond
the system-provided CoreGraphics and CoreText.

## Basic Usage

Import the module and create a ``Figure``:

```swift
import PlotSwift

let fig = Figure(width: 800, height: 600)
```

Add an ``Axes`` that fills the figure with default margins:

```swift
let ax = fig.addAxes()
```

Plot a line series and a scatter series on the same axes:

```swift
let x = [0.0, 1.0, 2.0, 3.0, 4.0]
let y = [0.0, 1.0, 4.0, 9.0, 16.0]

ax.plot(x, y, label: "x²")
ax.scatter(x, y.map { $0 * 0.9 }, marker: .circle, label: "noisy")
ax.setTitle("Quadratic Growth")
ax.setXLabel("x")
ax.setYLabel("y")
ax.legend()
```

Export the result:

```swift
// PNG — returns Data?
if let png = fig.renderToPNG() {
    try png.write(to: URL(fileURLWithPath: "plot.png"))
}

// SVG — returns String
let svg = fig.renderToSVG()
print(svg)
```

## Working with Subplots

Use the module-level ``subplots(rows:cols:figsize:)`` convenience function to
create a grid of axes in one call, matching matplotlib's `plt.subplots()`:

```swift
let (fig, axes) = subplots(rows: 2, cols: 2, figsize: (1200, 900))

axes[0][0].plot([1, 2, 3], [3, 1, 2])
axes[0][0].setTitle("Top Left")

axes[0][1].bar([1, 2, 3], [5, 3, 7])
axes[0][1].setTitle("Top Right")

axes[1][0].scatter([1, 2, 3], [4, 6, 2])
axes[1][0].setTitle("Bottom Left")

axes[1][1].hist([1, 1, 2, 3, 3, 3, 4, 4])
axes[1][1].setTitle("Bottom Right")

let png = fig.renderToPNG(scale: 2.0)
```

## Colors

Colors can be constructed in several ways:

```swift
// Named component values (0–1 range)
let crimson = Color(red: 0.86, green: 0.08, blue: 0.24)

// Hex string — returns nil for invalid input
let sky = Color(hex: "#87CEEB")!

// Named color string
let forest = Color(name: "green")!

// Static constants
let line1Color: Color = .blue
let background: Color = .white
```

Predefined constants cover the common web colors: `.black`, `.white`, `.red`,
`.green`, `.blue`, `.yellow`, `.cyan`, `.magenta`, `.orange`, `.purple`, `.gray`,
`.lightGray`, `.darkGray`, `.clear`.

## Color Palettes

When you do not specify a color for a series, ``Axes`` cycles through a
``ColorPalette`` automatically. The default palette is ``ColorPalette/tab10``,
which matches matplotlib's default:

```swift
// Use a different palette
let ax = Axes(plotArea: PlotArea(bounds: bounds), palette: .set1)

// Sample a continuous palette
let heatColor = ColorPalette.viridis.color(at: 0.75)
```

Available categorical palettes: `tab10`, `tab20`, `set1`, `set2`, `set3`,
`paired`, `dark2`, `accent`, `pastel1`, `pastel2`.

Available continuous palettes: `viridis`, `plasma`, `magma`, `inferno`,
`coolwarm`, `rdylgn`, `spectral`.
