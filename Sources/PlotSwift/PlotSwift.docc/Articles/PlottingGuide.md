# Plotting Guide

Create line, scatter, bar, and histogram plots and customize them with labels,
annotations, and grid styling.

## Overview

All plot content lives on an ``Axes`` instance. You create axes by calling
``Figure/addAxes(rect:)`` or ``Figure/addSubplot(rows:cols:index:)`` on a
``Figure``, then call the plot methods below. The axes auto-scales its limits to
fit all data unless you set explicit limits with ``Axes/setXLim(_:_:)`` /
``Axes/setYLim(_:_:)``.

## Line Plots

``Axes/plot(_:_:color:lineStyle:lineWidth:marker:markerSize:label:)`` draws a
connected line through the data points:

```swift
let x = stride(from: 0.0, through: .pi * 4, by: 0.05).map { $0 }

ax.plot(x, x.map { sin($0) },
        color: .blue, lineStyle: .solid, lineWidth: 2,
        label: "sin")

ax.plot(x, x.map { cos($0) },
        color: .red, lineStyle: .dashed, lineWidth: 1.5,
        label: "cos")
```

When color is `nil`, the next color from the active ``ColorPalette`` is used.

Pass only a y-array to use sequential indices as x-values:

```swift
ax.plot([3.0, 1.0, 4.0, 1.0, 5.0, 9.0], label: "π digits")
```

Available ``LineStyle`` values: `.solid`, `.dashed`, `.dotted`, `.dashDot`, `.none`.

Available ``MarkerStyle`` values: `.none`, `.circle`, `.square`, `.diamond`,
`.triangleUp`, `.triangleDown`, `.plus`, `.cross`, `.star`, `.dot`.

## Scatter Plots

``Axes/scatter(_:_:color:marker:markerSize:alpha:label:)`` draws markers without
connecting lines and accepts an opacity parameter:

```swift
ax.scatter(x, y,
           color: .orange, marker: .diamond,
           markerSize: 8, alpha: 0.6,
           label: "observations")
```

## Bar Charts

``Axes/bar(_:_:width:bottom:color:edgeColor:edgeWidth:label:)`` draws vertical bars:

```swift
let categories = [1.0, 2.0, 3.0, 4.0]
let values     = [5.0, 8.0, 3.0, 7.0]

ax.bar(categories, values, width: 0.6,
       color: .steelBlue, edgeColor: .black, edgeWidth: 0.5,
       label: "Q1 sales")
```

Stack bars by passing a `bottom` array equal in length to `heights`:

```swift
let baseValues = [2.0, 3.0, 1.0, 4.0]
ax.bar(categories, baseValues, label: "Base")
ax.bar(categories, [3.0, 5.0, 2.0, 3.0], bottom: baseValues, label: "Top")
```

``Axes/barh(_:_:height:left:color:edgeColor:edgeWidth:label:)`` produces
horizontal bars with the same parameters mapped to the horizontal axis.

## Histograms

``Axes/hist(_:bins:range:density:cumulative:color:edgeColor:alpha:label:)``
bins a flat array of values and plots the result as a bar chart:

```swift
let samples: [Double] = (0..<500).map { _ in Double.random(in: 0...10) }

let (counts, edges) = ax.hist(samples,
                               bins: .count(20),
                               density: false,
                               color: .blue, alpha: 0.7,
                               label: "samples")
```

``HistogramBins`` options:

| Case | Behavior |
|------|----------|
| `.auto` | Sturges' rule: `ceil(log2(n)) + 1` bins |
| `.count(k)` | `k` equal-width bins |
| `.edges([…])` | Explicit bin-edge array |
| `.width(w)` | Bins of width `w` starting at the data minimum |

Pass `density: true` to normalize so that the histogram area integrates to 1.
Pass `cumulative: true` to accumulate counts from left to right.

## Axis Labels and Title

```swift
ax.setTitle("Annual Revenue")
ax.setXLabel("Year")
ax.setYLabel("Revenue (USD)")
```

All three methods accept an optional ``TextStyle`` for custom typography:

```swift
let bold = TextStyle(fontSize: 16, fontWeight: .bold, color: .black)
ax.setTitle("Annual Revenue", style: bold)
```

## Grid

```swift
ax.grid(true)                                    // default: light gray solid
ax.grid(true, color: .lightGray, lineStyle: .dotted, lineWidth: 0.5)
ax.grid(false)                                   // hide
```

## Legend

Call ``Axes/legend(position:)`` after adding series with `label` values:

```swift
ax.legend()                           // defaults to .topRight
ax.legend(position: .bottomLeft)
```

``LegendPosition`` options: `.topRight`, `.topLeft`, `.bottomRight`, `.bottomLeft`.

## Axis Limits

```swift
ax.setXLim(0, 100)
ax.setYLim(-1, 1)
```

Pass `nil` (the default) to restore auto-scaling for that axis.

## Annotations

Text annotations point to data locations and can carry an arrow:

```swift
ax.annotate("peak",
            xy: (3.14, 1.0),
            xytext: (4.0, 0.8),
            arrowprops: ArrowProps(arrowStyle: .simple, color: .black),
            fontsize: 11)
```

Reference lines span the full plot area:

```swift
ax.axhline(y: 0, color: .darkGray, lineStyle: .dashed)  // horizontal
ax.axvline(x: 3.14, color: .red, lineStyle: .dotted)    // vertical
```

Shaded spans:

```swift
ax.axhspan(ymin: -0.5, ymax: 0.5, color: .yellow, alpha: 0.2)
ax.axvspan(xmin: 0, xmax: 1, color: .green, alpha: 0.15)
```

Fill between two curves:

```swift
ax.fillBetween(x, y1, y2, color: .blue, alpha: 0.25, label: "confidence")
```

Error bars:

```swift
ax.errorbar(x, y,
            yerr: .symmetric(0.2),
            color: .navy, capsize: 4, marker: .circle)
```

## Working Directly with DrawingContext

For full control, create a ``DrawingContext`` and render an axes into it before
adding additional custom drawing commands:

```swift
let ctx = DrawingContext()
ax.render(to: ctx)

// Overlay a custom watermark
ctx.setAlpha(0.1)
ctx.setFillColor(.gray)
ctx.text("DRAFT", x: 300, y: 300,
         style: TextStyle(fontSize: 72, fontWeight: .bold,
                          color: .gray, anchor: .middle))

let png = ctx.renderToPNG(size: CGSize(width: 800, height: 600))
```
