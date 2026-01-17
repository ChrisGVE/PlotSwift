# First Principles - PlotSwift

This document establishes the foundational principles that guide all design and implementation decisions for PlotSwift.

## Principle 1: Test Driven Development

**Philosophy**: Systematic TDD - write unit tests immediately after each logical unit of code.

**Implementation implications**:

- Each logical unit (function, struct, enum, method) needs at least one unit test
- Cover edge cases and validation errors (multiple tests per unit)
- Run tests after atomic changes; amend tests only after first run
- Use LSP to identify calling/called code relationships
- Test all compilation combinations: standalone, with NumericSwift, with ArraySwift, and with both

## Principle 2: Leverage Existing Solutions

**Philosophy**: Reuse mature Swift and Apple development frameworks rather than reinventing functionality; optionally integrate with NumericSwift and ArraySwift when available.

**Implementation implications**:

- Use CoreGraphics, CoreText, and ImageIO for rendering and export
- Use Foundation types where appropriate (CGPoint, CGRect, CGAffineTransform)
- Follow Apple Human Interface Guidelines for default styling choices
- Use conditional compilation (`#if canImport(NumericSwift)`) for optional library integration
- When NumericSwift/ArraySwift are present, leverage their capabilities (NDArray, statistical functions, etc.)
- When sister libraries are absent, provide simpler fallback implementations using standard Swift
- Maintain loose coupling: PlotSwift must compile and function fully without sister libraries

## Principle 3: Familiar Developer Experience

**Philosophy**: Provide a similar developer experience to matplotlib, seaborn, and manim - the libraries that inspire PlotSwift.

**Implementation implications**:

- API naming conventions should feel familiar to matplotlib/seaborn users (e.g., `plot()`, `scatter()`, `bar()`, `hist()`)
- Support method chaining and fluent interfaces for concise plot construction
- Provide sensible defaults that produce good-looking plots without configuration ("just works")
- Use similar parameter names and semantics where applicable (e.g., `color`, `linewidth`, `marker`)
- Support shorthand format strings like matplotlib (e.g., `"ro-"` for red circles with lines)
- Maintain conceptual consistency: Figure/Axes hierarchy, data-driven styling, layered composition

## Principle 4: Vector-First Rendering

**Philosophy**: All drawing operations are stored as commands for scale-free, resolution-independent rendering.

**Implementation implications**:

- Use retained-mode graphics: store `DrawingCommand` instances, not rasterized output
- Support multiple export formats (PNG, PDF, SVG) from the same command list
- Enable scaling and transformation without quality loss
- Compute bounds dynamically from stored commands
- Defer actual rendering until export time
- Support replay and modification of drawing commands

## Principle 5: Composable Architecture

**Philosophy**: Build complex visualizations from simple, composable primitives that can be combined freely.

**Implementation implications**:

- Separate concerns: data processing, coordinate transformation, rendering
- Allow independent customization of each plot element (axes, legend, title, data series)
- Support layering multiple plot types on the same axes
- Enable subplot/grid layouts through composition
- Use protocols to define common interfaces for extensibility
- Prefer composition over inheritance for combining behaviors

## Principle 6: Progressive Disclosure

**Philosophy**: Simple things should be simple; complex things should be possible.

**Implementation implications**:

- Provide high-level convenience APIs for common tasks (`plot(x, y)`)
- Expose lower-level APIs for fine-grained control when needed
- Use sensible defaults at every level
- Allow overriding any default through explicit parameters
- Document both quick-start patterns and advanced customization
- Avoid requiring boilerplate for basic plots
