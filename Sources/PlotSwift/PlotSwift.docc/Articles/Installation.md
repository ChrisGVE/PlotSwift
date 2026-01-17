# Installation

Add PlotSwift to your Swift project.

## Overview

PlotSwift is distributed via Swift Package Manager. It requires Swift 5.9+ and supports iOS 15+ and macOS 12+.

## Swift Package Manager

### Using Package.swift

Add PlotSwift to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/ChrisGVE/PlotSwift.git", from: "0.1.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["PlotSwift"]
)
```

### Using Xcode

1. Open your project in Xcode
2. Go to File > Add Package Dependencies
3. Enter the repository URL: `https://github.com/ChrisGVE/PlotSwift.git`
4. Select the version and click Add Package

## Requirements

- Swift 5.9 or later
- iOS 15.0+ or macOS 12.0+
- Frameworks: CoreGraphics, CoreText, ImageIO (all included in Apple platforms)

## Importing

After installation, import PlotSwift in your Swift files:

```swift
import PlotSwift
```
