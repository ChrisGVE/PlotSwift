# PlotSwift Gap Analysis Report

**Date**: 2026-01-17
**Compared Against**: matplotlib, seaborn, manim
**Current PlotSwift Version**: Pre-0.1.0

---

## Executive Summary

PlotSwift currently provides a solid **low-level vector graphics foundation** (DrawingContext, DrawingCommand) with export capabilities (PNG, PDF, SVG). However, it lacks the **high-level plotting APIs** that make matplotlib/seaborn/manim productive for data visualization.

**Current State**: ~820 lines of code providing drawing primitives
**Gap**: Missing the entire "plotting" layer that sits on top of drawing primitives

---

## Current PlotSwift Capabilities

### What We Have

| Component | Status | Notes |
|-----------|--------|-------|
| **Color** | ✅ Complete | RGB, hex, named colors, predefined palette, CGColor conversion |
| **TextStyle** | ✅ Complete | Font family, size, weight, color, anchor |
| **LineStyle** | ✅ Complete | Solid, dashed, dotted, dash-dot, none |
| **MarkerStyle** | ✅ Defined | Enum exists but not rendered |
| **DrawingCommand** | ✅ Complete | Path ops, shapes, text, transforms, styles, clipping |
| **DrawingContext** | ✅ Complete | Retained-mode graphics, render to CG context |
| **PNG Export** | ✅ Complete | Via ImageIO |
| **PDF Export** | ✅ Complete | Via CGContext |
| **SVG Export** | ✅ Partial | Missing arc-to-path conversion |

---

## Gap Analysis by Category

### 1. High-Level Plotting Functions

**Status**: ❌ NOT IMPLEMENTED

PlotSwift needs a high-level API layer similar to matplotlib.pyplot.

| matplotlib | seaborn | Priority | Description |
|------------|---------|----------|-------------|
| `plot()` | `lineplot()` | **Critical** | Line plots - the most basic plot type |
| `scatter()` | `scatterplot()` | **Critical** | Scatter plots with markers |
| `bar()` / `barh()` | `barplot()` | **High** | Vertical/horizontal bar charts |
| `hist()` | `histplot()` | **High** | Histograms |
| `pie()` | - | Medium | Pie charts |
| `boxplot()` | `boxplot()` | Medium | Box-and-whisker plots |
| `violinplot()` | `violinplot()` | Medium | Violin plots |
| `errorbar()` | - | Medium | Error bar plots |
| `fill_between()` | - | Medium | Filled area plots |
| `stackplot()` | - | Medium | Stacked area charts |
| `stem()` | - | Low | Stem plots |
| `step()` | - | Low | Step plots |
| `imshow()` | `heatmap()` | Medium | Image/matrix display |
| `contour()` / `contourf()` | - | Low | Contour plots |
| `quiver()` | - | Low | Vector field plots |
| `streamplot()` | - | Low | Streamline plots |

### 2. Figure & Axes Management

**Status**: ❌ NOT IMPLEMENTED

The core organizational structure for multi-plot figures.

| Feature | matplotlib | Priority | Description |
|---------|------------|----------|-------------|
| `Figure` | `plt.figure()` | **Critical** | Container for one or more Axes |
| `Axes` | `plt.axes()` | **Critical** | Single plot area with data, ticks, labels |
| `subplot()` | `plt.subplot()` | **High** | Add subplot to current figure |
| `subplots()` | `plt.subplots()` | **High** | Create figure with subplot grid |
| `GridSpec` | `GridSpec` | Medium | Complex subplot layouts |
| `subplot_mosaic()` | `subplot_mosaic()` | Low | Named subplot layouts |
| `twinx()` / `twiny()` | `ax.twinx()` | Medium | Secondary axes |
| `inset_axes()` | `inset_axes()` | Low | Inset axes within axes |

### 3. Axis Configuration

**Status**: ❌ NOT IMPLEMENTED

Controls for axis appearance and behavior.

| Feature | matplotlib | Priority | Description |
|---------|------------|----------|-------------|
| `set_xlabel()` / `set_ylabel()` | `ax.set_xlabel()` | **Critical** | Axis labels |
| `set_title()` | `ax.set_title()` | **Critical** | Plot title |
| `set_xlim()` / `set_ylim()` | `ax.set_xlim()` | **Critical** | Axis limits |
| `set_xticks()` / `set_yticks()` | `ax.set_xticks()` | **High** | Tick positions |
| `set_xticklabels()` | `ax.set_xticklabels()` | **High** | Tick labels |
| `tick_params()` | `ax.tick_params()` | Medium | Tick appearance |
| `grid()` | `ax.grid()` | **High** | Grid lines |
| `set_xscale()` / `set_yscale()` | `ax.set_xscale()` | Medium | Log/symlog scales |
| `set_aspect()` | `ax.set_aspect()` | Medium | Aspect ratio |
| `invert_xaxis()` / `invert_yaxis()` | `ax.invert_xaxis()` | Low | Invert axis direction |
| Spine customization | `ax.spines` | Low | Axis border styling |

### 4. Legends

**Status**: ❌ NOT IMPLEMENTED

| Feature | matplotlib | Priority | Description |
|---------|------------|----------|-------------|
| `legend()` | `ax.legend()` | **High** | Create legend |
| Legend location | `loc` parameter | **High** | Position legend |
| Legend handles/labels | Custom entries | Medium | Manual legend entries |
| Legend styling | `frameon`, `fancybox` | Low | Visual customization |

### 5. Colormaps & Colorbars

**Status**: ❌ NOT IMPLEMENTED (only basic Color exists)

| Feature | matplotlib/seaborn | Priority | Description |
|---------|-------------------|----------|-------------|
| Named colormaps | `plt.cm.viridis` | **High** | Perceptually uniform maps |
| Sequential colormaps | `Blues`, `Reds` | **High** | Single-hue progressions |
| Diverging colormaps | `RdBu`, `coolwarm` | Medium | Two-ended scales |
| Qualitative colormaps | `Set1`, `tab10` | **High** | Categorical colors |
| Custom colormaps | `LinearSegmentedColormap` | Low | User-defined maps |
| `colorbar()` | `plt.colorbar()` | **High** | Color scale reference |
| Color normalization | `Normalize`, `LogNorm` | Medium | Value-to-color mapping |
| seaborn palettes | `sns.color_palette()` | Medium | Statistical palettes |

### 6. Annotations & Text

**Status**: ⚠️ PARTIAL (basic text exists)

| Feature | matplotlib | Priority | Description |
|---------|------------|----------|-------------|
| `text()` | `ax.text()` | ✅ Exists | Basic text (PlotSwift has this) |
| `annotate()` | `ax.annotate()` | **High** | Text with arrows |
| `axhline()` / `axvline()` | `ax.axhline()` | Medium | Reference lines |
| `axhspan()` / `axvspan()` | `ax.axhspan()` | Medium | Reference regions |
| Math text / LaTeX | `r'$\alpha$'` | Medium | Mathematical notation |
| Text rotation | `rotation` param | Medium | Angled text |

### 7. Statistical Visualizations (seaborn-inspired)

**Status**: ❌ NOT IMPLEMENTED

| Feature | seaborn | Priority | Description |
|---------|---------|----------|-------------|
| `kdeplot()` | Distribution | Medium | Kernel density estimate |
| `ecdfplot()` | Distribution | Low | Empirical CDF |
| `rugplot()` | Distribution | Low | Marginal ticks |
| `regplot()` / `lmplot()` | Regression | Medium | Linear regression plots |
| `residplot()` | Regression | Low | Residual plots |
| `jointplot()` | Multi-plot | Medium | Bivariate with marginals |
| `pairplot()` | Multi-plot | Medium | Pairwise relationships |
| `catplot()` | Categorical | Medium | Figure-level categorical |
| `stripplot()` / `swarmplot()` | Categorical | Low | Jittered categorical |
| `pointplot()` | Categorical | Low | Point estimates |
| `countplot()` | Categorical | Low | Count bars |
| `clustermap()` | Matrix | Low | Hierarchical clustering |
| FacetGrid | Multi-plot | Medium | Faceted subplots |

### 8. Animation (manim-inspired)

**Status**: ❌ NOT IMPLEMENTED

| Feature | manim | Priority | Description |
|---------|-------|----------|-------------|
| `Scene` | Scene class | Medium | Animation container |
| `Mobject` | Base object | Medium | Animatable objects |
| `Create` | Animation | Medium | Draw-in animation |
| `FadeIn` / `FadeOut` | Animation | Medium | Opacity animations |
| `Transform` | Animation | Medium | Morph between objects |
| `animate` syntax | `.animate.method()` | Medium | Method animation |
| `Updater` | Dynamic updates | Low | Frame-by-frame updates |
| Camera control | `MovingCamera` | Low | Pan/zoom animations |
| Timeline | `self.play()` | Medium | Sequenced animations |
| Video export | Scene rendering | Low | MP4/GIF output |

### 9. Data Integration

**Status**: ❌ NOT IMPLEMENTED

| Feature | Priority | Description |
|---------|----------|-------------|
| Array input | **Critical** | Accept `[Double]` for x, y data |
| NumericSwift integration | **High** | Use NumericSwift arrays when available |
| ArraySwift integration | **High** | Use NDArray when available |
| DataFrame-like input | Low | Column-based data selection |
| Auto-ranging | **High** | Compute axis limits from data |
| Data transformation | Medium | Log, sqrt, etc. transforms |

### 10. Styling & Themes

**Status**: ⚠️ PARTIAL (basic styles exist)

| Feature | matplotlib/seaborn | Priority | Description |
|---------|-------------------|----------|-------------|
| Default styles | `plt.style.use()` | **High** | Named style presets |
| seaborn themes | `sns.set_theme()` | Medium | Statistical themes |
| RC params | `plt.rcParams` | Medium | Global defaults |
| Context scaling | `sns.set_context()` | Low | paper/notebook/talk/poster |

### 11. Interactive Features

**Status**: ❌ NOT IMPLEMENTED (low priority for 0.1.0)

| Feature | Priority | Description |
|---------|----------|-------------|
| Zoom/pan | Low | Interactive navigation |
| Tooltips | Low | Hover information |
| Click events | Low | User interaction |

---

## Recommended Implementation Phases

### Phase 1: Core Plotting (0.1.x - 0.2.x)
**Goal**: Basic plotting capability comparable to simple matplotlib usage

1. **Figure/Axes architecture** - The foundation for all plots
2. **plot()** - Line plots with markers
3. **scatter()** - Scatter plots
4. **Axis configuration** - Labels, titles, limits, ticks, grid
5. **Legend** - Basic legend support
6. **Auto-ranging** - Compute limits from data
7. **Default colormap** - Basic sequential/categorical palettes

### Phase 2: Extended Plot Types (0.3.x - 0.4.x)
**Goal**: Cover common statistical and categorical visualizations

1. **bar() / barh()** - Bar charts
2. **hist()** - Histograms
3. **boxplot()** - Box plots
4. **violinplot()** - Violin plots
5. **pie()** - Pie charts
6. **errorbar()** - Error bars
7. **fill_between()** - Area fills
8. **heatmap()** - Matrix visualization
9. **Annotations** - annotate(), reference lines

### Phase 3: Advanced Features (0.5.x - 0.6.x)
**Goal**: Statistical and multi-plot capabilities

1. **Subplots** - subplots(), GridSpec
2. **Colormaps** - Full colormap support, colorbar
3. **Statistical plots** - KDE, regression, distributions
4. **Pairplot / jointplot** - Multi-variable visualization
5. **Themes/styles** - Named presets

### Phase 4: Animation (0.7.x+)
**Goal**: Manim-inspired animation capabilities

1. **Scene** - Animation container
2. **Basic animations** - Create, FadeIn, FadeOut, Transform
3. **Animate syntax** - Method chaining for animations
4. **Timeline** - play() sequencing
5. **Video export** - MP4/GIF rendering

---

## Architectural Recommendations

### 1. Figure/Axes Hierarchy
```swift
Figure
├── Axes[]
│   ├── DataSeries[] (lines, scatter, bars, etc.)
│   ├── XAxis, YAxis
│   ├── Legend
│   ├── Title
│   └── Annotations[]
└── Layout (spacing, size)
```

### 2. Protocol-Based Extensibility
```swift
protocol Plottable {
    func render(to context: DrawingContext, axes: Axes)
}

protocol Animatable {
    func interpolate(from: Self, to: Self, t: Double) -> Self
}
```

### 3. Fluent API Design
```swift
// Target API style
let fig = Figure()
let ax = fig.addAxes()
ax.plot(x, y, color: .blue, lineStyle: .solid, marker: .circle)
  .scatter(x2, y2, color: .red, size: 10)
  .setXLabel("Time")
  .setYLabel("Value")
  .setTitle("My Plot")
  .legend()

let png = fig.renderToPNG(size: CGSize(width: 800, height: 600))
```

### 4. NumericSwift/ArraySwift Integration
```swift
#if canImport(NumericSwift)
import NumericSwift

extension Axes {
    func plot(_ x: [Double], _ y: [Double], ...) { ... }

    // When NumericSwift available, add statistical helpers
    func hist(_ data: [Double], bins: Int = 10, density: Bool = false) {
        let (counts, edges) = NumericSwift.histogram(data, bins: bins)
        // render histogram
    }
}
#endif
```

---

## Conclusion

PlotSwift has a solid foundation with its DrawingContext/DrawingCommand architecture. The primary gap is the absence of a high-level plotting API layer.

**Immediate priorities for 0.1.0**:
- The current low-level API is sufficient for release as a "drawing library"
- Document that high-level plotting APIs are planned for future versions

**For a full plotting library (0.2.0+)**:
- Implement Figure/Axes architecture
- Add plot(), scatter(), bar(), hist() at minimum
- Implement axis labels, titles, legends
- Add basic colormap support

The gap is significant but addressable. The existing code provides the right foundation - it just needs the plotting layer built on top.
