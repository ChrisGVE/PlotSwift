# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-07

Initial release.

### Added

- **Drawing primitives** — `DrawingContext` with a retained `DrawingCommand` list
  supporting paths (`moveTo`, `lineTo`, `curveTo`, `quadCurveTo`, `closePath`),
  shapes (`rect`, `ellipse`, `circle`, `arc`), text, and full 2-D transform stack
  (`translate`, `scale`, `rotate`, `saveState`, `restoreState`).
- **Figure / Axes API** — `Figure` container with `addAxes(rect:)` and
  `addSubplot(rows:cols:index:)` for single and grid layouts; module-level
  `subplots(rows:cols:figsize:)` convenience mirroring matplotlib's signature.
- **Line and scatter plots** — `Axes.plot(_:_:)` for connected line series and
  `Axes.scatter(_:_:)` for marker-only series, both with automatic color cycling.
- **Bar charts** — `Axes.bar(_:_:)` for vertical bars and `Axes.barh(_:_:)` for
  horizontal bars, with `bottom`/`left` parameters for stacking.
- **Histograms** — `Axes.hist(_:bins:)` with four binning strategies (`auto`,
  `count`, `edges`, `width`), density normalization, and cumulative mode.
- **Color system** — `Color` type with RGB, hex-string, and named-color
  construction; alpha support; `withAlpha(_:)` derivation; full set of named
  constants (black, white, red, green, blue, yellow, cyan, magenta, orange,
  purple, gray, lightGray, darkGray, clear).
- **Color palettes** — `ColorPalette` with ten categorical palettes (`tab10`,
  `tab20`, `set1`, `set2`, `set3`, `paired`, `dark2`, `accent`, `pastel1`,
  `pastel2`) and seven continuous/diverging palettes (`viridis`, `plasma`,
  `magma`, `inferno`, `coolwarm`, `rdylgn`, `spectral`); `color(at:)` for
  linear interpolation.
- **Tick generation** — `TickGenerator` for human-friendly axis tick positions
  and labels; `DataRange.niceExpanded(targetTicks:)` for axis boundary rounding.
- **Coordinate transform** — `CoordinateTransform` protocol and `LinearTransform`
  concrete type mapping data space to pixel space.
- **SVG export** — `DrawingContext.renderToSVG(size:)` and `Figure.renderToSVG()`
  producing a complete `<svg>` document.
- **PNG export** — `DrawingContext.renderToPNG(size:scale:)` and
  `Figure.renderToPNG(scale:)` with optional Retina scale factor.
- **PDF export** — `DrawingContext.renderToPDF(size:)` and `Figure.renderToPDF()`
  via CoreGraphics PDF context.
- **Annotations** — `Axes.annotate(_:xy:xytext:arrowprops:)` for labelled arrows
  with `ArrowStyle` options (simple, fancy, wedge); `Axes.axhline` /
  `Axes.axvline` for reference lines; `Axes.axhspan` / `Axes.axvspan` for
  shaded bands.
- **Error bars** — `Axes.errorbar(_:_:yerr:xerr:)` with symmetric, per-point
  symmetric, and asymmetric `ErrorBarValue` specifications and a configurable
  cap size.
- **Fill between** — `Axes.fillBetween(_:_:_:)` to shade the region between two
  curves or between a curve and zero, with optional edge stroke.
- **Styling types** — `TextStyle` (font family, size, weight, anchor),
  `LineStyle` (solid, dashed, dotted, dash-dot, none), `MarkerStyle` (circle,
  square, diamond, triangle variants, plus, cross, star, dot).
- **Legend and grid** — `Axes.legend(position:)` with four corner positions
  (topRight, topLeft, bottomRight, bottomLeft); `Axes.grid(_:color:lineStyle:lineWidth:)`.
- **DocC documentation catalog** — landing page, Getting Started article,
  Plotting Guide, and Export Formats article.
- **Multi-platform support** — iOS 15+, macOS 12+, visionOS 1+, watchOS 8+,
  tvOS 15+.

[Unreleased]: https://github.com/ChrisGVE/PlotSwift/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ChrisGVE/PlotSwift/releases/tag/v0.1.0
