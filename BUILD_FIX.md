# Fixing RevenueCat Build Errors

## Problem
Xcode is showing build errors related to RevenueCat package:
- "no more rows available" in build database
- "internal inconsistency error: unexpected incomplete target"

## Solutions (try in order)

### Solution 1: Clean Build Folder and Restart Xcode
1. In Xcode, go to **Product → Clean Build Folder** (Shift+Cmd+K)
2. Quit Xcode completely
3. Reopen the project
4. Try building again

### Solution 2: Remove RevenueCatUI Dependency
RevenueCatUI is added but not used in the code. Remove it:

1. In Xcode, select the project in navigator
2. Select the **Ghost** target
3. Go to **General** tab → **Frameworks, Libraries, and Embedded Content**
4. Find **RevenueCatUI** and click the **-** button to remove it
5. Go to **Package Dependencies** tab
6. Make sure only **RevenueCat** is listed (not RevenueCatUI)
7. Clean build folder and rebuild

### Solution 3: Reset Package Cache
1. In Xcode, go to **File → Packages → Reset Package Caches**
2. Then **File → Packages → Resolve Package Versions**
3. Clean build folder
4. Rebuild

### Solution 4: Manual Package Reset
If the above doesn't work:

1. Close Xcode
2. Delete package cache:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Ghost-*
   rm -rf ~/Library/Caches/org.swift.swiftpm
   ```
3. Reopen Xcode
4. Xcode will re-download packages
5. Clean and rebuild

### Solution 5: Re-add RevenueCat Package
If nothing works, re-add the package:

1. In Xcode, select project → **Package Dependencies** tab
2. Remove the RevenueCat package (if possible)
3. Add it again:
   - Click **+** button
   - Enter URL: `https://github.com/RevenueCat/purchases-ios-spm`
   - Select version: **Up to Next Major Version** starting from **5.55.3**
   - Add only **RevenueCat** product (NOT RevenueCatUI)
   - Click **Add Package**

## Current Package Configuration
- Package URL: `https://github.com/RevenueCat/purchases-ios-spm`
- Version: Up to Next Major Version from 5.55.3
- Products used: **RevenueCat** only (RevenueCatUI should be removed)

## After Fixing
Once the build succeeds, make sure:
- Only `import RevenueCat` is used in code (not RevenueCatUI)
- The project builds without errors
- You can run the app on simulator/device
