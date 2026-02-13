# Setting Up Xcode Project

This document provides step-by-step instructions to create a complete Xcode iOS app project in this repository.

## Option 1: Using Xcode GUI (Recommended for Getting Started)

### Step 1: Create the Xcode Project

1. Open Xcode
2. Go to **File** → **New** → **Project**
3. Select **iOS** platform
4. Choose **App** template
5. Configure the project:
   - **Product Name**: `LanguageGame`
   - **Team**: None (or your team)
   - **Organization Identifier**: `com.example` (or your identifier)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (we'll use UserDefaults)
6. **Choose where to save**: Select your `language-game` repository folder
7. Click **Create**

### Step 2: Configure the Project Structure

Xcode will create a default project. You can either:

**Option A: Keep existing code and organize**
1. Delete the auto-generated source files EXCEPT:
   - Keep the `LanguageGameApp.swift` wrapper
   - Keep `Info.plist` and `Preview Content`
   
2. The file structure should look like:
   ```
   language-game/
   ├── LanguageGame.xcodeproj/
   ├── LanguageGame/
   │   ├── LanguageGameApp.swift
   │   ├── Info.plist
   │   └── Preview Content/
   ├── Package.swift
   ├── Sources/LanguageGame/
   │   ├── App/
   │   ├── Games/
   │   ├── Models/
   │   ├── Services/
   │   ├── Views/
   │   └── ...
   └── README.md
   ```

**Option B: Merge sources into app target** (cleaner)
1. Move everything from `Sources/LanguageGame/*` into the `LanguageGame/` folder created by Xcode
2. Delete the `Sources/` folder once moved
3. Update `Package.swift` to only define the library (optional, can delete if not using as a package)

### Step 3: Add Yams Dependency

1. In Xcode, select your project
2. Go to **Package Dependencies**
3. Click **+** button
4. Enter: `https://github.com/jpsim/Yams.git`
5. Select version **5.0.0** or later
6. Click **Add Package**
7. Select the `LanguageGame` app target in the dialog

### Step 4: Build and Run

1. Select the `LanguageGame` scheme at the top of Xcode
2. Select an iOS 17+ simulator (or your device)
3. Press **Cmd+R** to build and run

---

## Option 2: Automated Setup Script

Run this script to set up an Xcode project structure automatically:

```bash
#!/bin/bash
cd /Users/davids/Documents/Source/git/language-game

# Create the app bundle folder structure
mkdir -p LanguageGame

# Copy app wrapper files
cat > LanguageGame/LanguageGameApp.swift << 'EOF'
import SwiftUI

@main
struct LanguageGameApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Loading...")
        }
    }
}
EOF

# Create Info.plist
cat > LanguageGame/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UIApplicationSceneManifestKey</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
        <key>UISceneConfigurations</key>
        <dict/>
    </dict>
</dict>
</plist>
EOF

# Create Preview Content folder
mkdir -p "LanguageGame/Preview Content"

echo "✅ Xcode project structure created!"
echo "📝 Next: Open LanguageGame.xcodeproj in Xcode and add Yams package dependency"
```

Save the above as `setup_xcode.sh` and run:
```bash
chmod +x setup_xcode.sh
./setup_xcode.sh
```

Then open Xcode and create a new project as described in Option 1, Step 1.

---

## Recommended Final Structure

After setup, your repo should have:

```
language-game/
├── LanguageGame.xcodeproj/        # Created by Xcode
├── LanguageGame/                   # App target (created by Xcode)
│   ├── LanguageGameApp.swift
│   ├── Info.plist
│   └── Preview Content/
├── Sources/LanguageGame/           # Our Swift Package (can keep as reference)
│   ├── App/
│   ├── Games/
│   ├── Models/
│   ├── Services/
│   └── Views/
├── Package.swift
├── README.md
├── .gitignore
└── XCODE_SETUP.md
```

---

## Consolidating to Single Folder (Optional)

If you prefer to have just one copy of the code:

```bash
# After creating the Xcode project:
cp -r Sources/LanguageGame/* LanguageGame/
rm -rf Sources/
```

Then update `.gitignore` if needed. This simplifies the structure to a single target.

---

## Verifying Dependencies

Once in Xcode:

1. Select the project in the navigator
2. Select the `LanguageGame` target
3. Go to **Build Phases** → **Link Binary With Libraries**
4. Verify `YamsLibrary` is listed
5. Go to **Build Settings** and search for "Swift" to verify language version is Swift 5.9+

---

## Troubleshooting

**"Module not found: Yams"**
- Make sure you added the Yams package dependency to the app target
- Clean build folder (Cmd+Shift+K)
- Rebuild

**Preview not working**
- Make sure you're viewing a SwiftUI view
- The device must be set to a simulator running iOS 17+

**Git conflicts**
- The `.gitignore` file includes `/*.xcodeproj` - you may want to include the project:
  ```bash
  git add -f LanguageGame.xcodeproj/project.pbxproj
  ```

---

## Next Steps

1. Follow Option 1 or 2 above to create the project
2. Verify the project builds and runs
3. The app should launch to a blank screen initially
4. Go to Settings tab and enter a data repository URL
5. Tap "Fetch from Repository" to load content
6. Start playing games!

Need help? See README.md for full documentation.
