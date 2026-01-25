# Fix Missing Watch App Icons Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Generate all missing watchOS app icons so Xcode shows no empty slots in the asset catalog.

**Architecture:** Update the icon generation script to produce every size required by the Contents.json manifest, matching Xcode's expected filenames exactly.

**Tech Stack:** Swift script using AppKit for image generation, runs on macOS.

---

## Analysis

The Contents.json expects these icons (entries without `filename` are missing):

| Role | Size | Scale | Pixels | Subtype | Status |
|------|------|-------|--------|---------|--------|
| notificationCenter | 24x24 | 2x | 48 | 38mm | **MISSING** |
| notificationCenter | 27.5x27.5 | 2x | 55 | 42mm | **MISSING** |
| companionSettings | 29x29 | 2x | 58 | - | **MISSING** |
| companionSettings | 29x29 | 3x | 87 | - | **MISSING** |
| notificationCenter | 33x33 | 2x | 66 | 45mm | **MISSING** |
| appLauncher | 40x40 | 2x | 80 | 38mm | EXISTS |
| appLauncher | 44x44 | 2x | 88 | 40mm | EXISTS |
| appLauncher | 46x46 | 2x | 92 | 41mm | **MISSING** |
| appLauncher | 50x50 | 2x | 100 | 44mm | EXISTS |
| appLauncher | 51x51 | 2x | 102 | 45mm | EXISTS |
| appLauncher | 54x54 | 2x | 108 | 49mm | EXISTS |
| quickLook | 86x86 | 2x | 172 | 38mm | EXISTS |
| quickLook | 98x98 | 2x | 196 | 42mm | EXISTS |
| quickLook | 108x108 | 2x | 216 | 44mm | EXISTS |
| quickLook | 117x117 | 2x | 234 | 45mm | EXISTS |
| quickLook | 129x129 | 2x | 258 | 49mm | **MISSING** |
| watch-marketing | 1024x1024 | 1x | 1024 | - | EXISTS |

**Missing pixel sizes:** 48, 55, 58, 66, 87, 92, 258

---

## Task 1: Update Icon Generation Script

**Files:**
- Modify: `Scripts/generate_watch_icons.swift`

**Step 1: Replace the iconSizes array with complete list**

Replace lines 7-16 with:

```swift
// Icon sizes needed for watchOS - pixel sizes that match Contents.json expectations
// Format: pixel size to generate
let iconPixelSizes: [Int] = [
    48,   // notificationCenter 24x24@2x (38mm)
    55,   // notificationCenter 27.5x27.5@2x (42mm)
    58,   // companionSettings 29x29@2x
    66,   // notificationCenter 33x33@2x (45mm)
    80,   // appLauncher 40x40@2x (38mm)
    87,   // companionSettings 29x29@3x
    88,   // appLauncher 44x44@2x (40mm)
    92,   // appLauncher 46x46@2x (41mm)
    100,  // appLauncher 50x50@2x (44mm)
    102,  // appLauncher 51x51@2x (45mm)
    108,  // appLauncher 54x54@2x (49mm)
    172,  // quickLook 86x86@2x (38mm)
    196,  // quickLook 98x98@2x (42mm)
    216,  // quickLook 108x108@2x (44mm)
    234,  // quickLook 117x117@2x (45mm)
    258,  // quickLook 129x129@2x (49mm)
    1024, // watch-marketing 1024x1024@1x
]
```

**Step 2: Simplify the generation loop**

Replace lines 127-151 (the generation loop) with:

```swift
// Generate all icons
for pixelSize in iconPixelSizes {
    let filename = "AppIcon-\(pixelSize).png"
    let image = generateIcon(pixelSize: pixelSize)
    let path = "\(outputDir)/\(filename)"
    saveIcon(image, to: path)
}

print("\nDone! Generated \(iconPixelSizes.count) watch app icons.")
```

**Step 3: Remove the Contents.json generation code**

Delete lines 153-166 (the Contents.json generation). We'll update Contents.json manually to reference the correct filenames since Xcode's format is more complex with roles/subtypes.

---

## Task 2: Update Contents.json with Filenames

**Files:**
- Modify: `WatchGPT Watch App/Assets.xcassets/AppIcon.appiconset/Contents.json`

**Step 1: Add filename to each missing entry**

Update Contents.json to add `filename` fields for all missing entries:

```json
{
  "images" : [
    {
      "filename" : "AppIcon-48.png",
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "24x24",
      "subtype" : "38mm"
    },
    {
      "filename" : "AppIcon-55.png",
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "27.5x27.5",
      "subtype" : "42mm"
    },
    {
      "filename" : "AppIcon-58.png",
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-87.png",
      "idiom" : "watch",
      "role" : "companionSettings",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "AppIcon-66.png",
      "idiom" : "watch",
      "role" : "notificationCenter",
      "scale" : "2x",
      "size" : "33x33",
      "subtype" : "45mm"
    },
    {
      "filename" : "AppIcon-80.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "40x40",
      "subtype" : "38mm"
    },
    {
      "filename" : "AppIcon-88.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "44x44",
      "subtype" : "40mm"
    },
    {
      "filename" : "AppIcon-92.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "46x46",
      "subtype" : "41mm"
    },
    {
      "filename" : "AppIcon-100.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "50x50",
      "subtype" : "44mm"
    },
    {
      "filename" : "AppIcon-102.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "51x51",
      "subtype" : "45mm"
    },
    {
      "filename" : "AppIcon-108.png",
      "idiom" : "watch",
      "role" : "appLauncher",
      "scale" : "2x",
      "size" : "54x54",
      "subtype" : "49mm"
    },
    {
      "filename" : "AppIcon-172.png",
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "86x86",
      "subtype" : "38mm"
    },
    {
      "filename" : "AppIcon-196.png",
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "98x98",
      "subtype" : "42mm"
    },
    {
      "filename" : "AppIcon-216.png",
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "108x108",
      "subtype" : "44mm"
    },
    {
      "filename" : "AppIcon-234.png",
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "117x117",
      "subtype" : "45mm"
    },
    {
      "filename" : "AppIcon-258.png",
      "idiom" : "watch",
      "role" : "quickLook",
      "scale" : "2x",
      "size" : "129x129",
      "subtype" : "49mm"
    },
    {
      "filename" : "AppIcon-1024.png",
      "idiom" : "watch-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

---

## Task 3: Run the Updated Script

**Step 1: Run the icon generation script**

```bash
cd /Users/cheng/Projects/AppleWatchChatGPT
swift Scripts/generate_watch_icons.swift
```

**Expected output:**
```
Created: .../AppIcon-48.png
Created: .../AppIcon-55.png
Created: .../AppIcon-58.png
Created: .../AppIcon-66.png
Created: .../AppIcon-80.png
Created: .../AppIcon-87.png
Created: .../AppIcon-88.png
Created: .../AppIcon-92.png
Created: .../AppIcon-100.png
Created: .../AppIcon-102.png
Created: .../AppIcon-108.png
Created: .../AppIcon-172.png
Created: .../AppIcon-196.png
Created: .../AppIcon-216.png
Created: .../AppIcon-234.png
Created: .../AppIcon-258.png
Created: .../AppIcon-1024.png

Done! Generated 17 watch app icons.
```

**Step 2: Verify all icons exist**

```bash
ls -la "WatchGPT Watch App/Assets.xcassets/AppIcon.appiconset/"
```

Should show 17 PNG files plus Contents.json.

---

## Task 4: Verify in Xcode

**Step 1: Open project in Xcode**

```bash
open WatchGPT.xcodeproj
```

**Step 2: Navigate to asset catalog**

1. Select "WatchGPT Watch App" in the project navigator
2. Open Assets.xcassets
3. Select AppIcon
4. Verify all icon slots are now filled (no dashed outlines)

---

## Task 5: Commit Changes

**Step 1: Stage and commit**

```bash
git add Scripts/generate_watch_icons.swift
git add "WatchGPT Watch App/Assets.xcassets/AppIcon.appiconset/"
git commit -m "fix: generate all required watchOS app icon sizes

- Update script to generate all 17 required icon sizes
- Add missing icons: 48, 55, 58, 66, 87, 92, 258 pixels
- Update Contents.json with correct filename references

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```
