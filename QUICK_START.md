# Quick Start: Creating the Xcode Project

This guide walks you through creating the complete Xcode iOS app project in this repository in about 5 minutes.

## What You'll Have When Done

✅ A fully functional iOS app that you can:
- Open in Xcode
- Edit and extend
- Run on the iOS simulator
- Build and deploy to your iPhone

---

## Step-by-Step Setup

### Step 1: Open Xcode

1. Launch **Xcode**
2. Click **File** → **New** → **Project**

### Step 2: Create a New iOS App Project

1. You'll see the template chooser. Select **iOS** at the top
2. Choose the **App** template (it should have a phone icon)
3. Click **Next**

### Step 3: Configure Your Project

Fill in the following fields:

| Field | Value |
|-------|-------|
| **Product Name** | `LanguageGame` |
| **Team** | None (click dropdown, select "None") |
| **Organization Identifier** | `com.bisaya` |
| **Bundle Identifier** | *(auto-fills)* |
| **Interface** | `SwiftUI` |
| **Language** | `Swift` |
| **Use Core Data** | ☐ (unchecked) |
| **Include Tests** | ☐ (unchecked) |

Click **Next**

### Step 4: Choose Save Location

1. **Save in:** Navigate to `/Users/davids/Documents/Source/git/language-game`
2. Make sure **Create Git repository on my Mac** is **unchecked** (we already have git)
3. Click **Create**

⏳ **Wait for Xcode to finish indexing** (progress bar at the bottom of the window)

---

## Step 5: Set Up File Structure

Once the project opens:

### 5A. Copy Source Files

1. Open **Finder** and navigate to `/Users/davids/Documents/Source/git/language-game`

2. You should see:
   ```
   Sources/LanguageGame/
   ├── App/
   ├── Games/
   ├── Models/
   ├── Services/
   ├── Views/
   └── Utilities/
   ```

3. Select ALL of these folders (drag to select or Cmd+A)

4. **Copy** them (Cmd+C)

### 5B. Paste Into Xcode Target

1. Go back to Xcode
2. In the **Project Navigator** (left sidebar), expand the **LanguageGame** folder
3. Select the **LanguageGame** folder (blue folder icon)
4. Right-click → **Add Files to "LanguageGame"**
5. Navigate to the `Sources/LanguageGame` folder in Finder
6. Select all the folders (App, Games, Models, Services, Views, Utilities)
7. Make sure:
   - ✅ **Copy items if needed** is checked
   - ✅ **Create groups** is selected
   - ✅ **Add to targets: LanguageGame** is checked
8. Click **Add**

⏳ **Wait for indexing to complete**

---

## Step 6: Add Yams Dependency

This is needed to parse YAML files from the content repository.

1. In Xcode, click on the **LanguageGame** project (in the Project Navigator)
2. Go to the **Package Dependencies** tab (at the top, next to "Build Settings")
3. Click the **+** button at the bottom-left
4. A dialog appears. Enter:
   ```
   https://github.com/jpsim/Yams.git
   ```
5. Click **Add Package**
6. For **Version**, select **Up to Next Major: 5.0.0 < 6.0.0** automatically, then **Add Package**
7. Xcode asks which target to add it to. Select **LanguageGame** and click **Add Package**

⏳ **Wait for Xcode to resolve and download the package**

---

## Step 7: Update the Main App File

Since Xcode created a default app entry point, we need to replace it:

1. In Xcode, find **LanguageGameApp.swift** in the left sidebar
2. Replace its contents with this:
   ```swift
   import SwiftUI

   @main
   struct LanguageGameApp: App {
       @StateObject private var dataManager = DataManager()
       @StateObject private var gameManager = GameManager()
       
       var body: some Scene {
           WindowGroup {
               MainTabView()
                   .environmentObject(dataManager)
                   .environmentObject(gameManager)
           }
       }
   }
   ```
3. Press **Cmd+S** to save

---

## Step 8: Build and Run

1. At the top of Xcode, select a **simulator**:
   - Click the simulator dropdown (it shows "Any iOS Device" or similar)
   - Choose **iPhone 15** or later
   - Wait for the simulator to start (this takes ~30 seconds first time)

2. Press **Cmd+R** (or click the Play button) to build and run

3. **First build takes 2-3 minutes.** You'll see compilation progress at the bottom.

4. Once complete, the app should launch in the simulator showing the **Home** tab

---

## Step 9: Configure the App

1. In the app, tap the **Settings** tab (gear icon at bottom-right)

2. Enter:
   - **Student Name:** Your name
   - **Repository URL:** One of these options:
     ```
     https://github.com/yourusername/bisaya-learning-data.git
     /Users/davids/Documents/Source/git/bisaya-learning-data
     file:///Users/davids/Documents/Source/git/bisaya-learning-data
     ```

3. Tap **Fetch from Repository**

4. You should see:
   ```
   Data loaded successfully!
   Vocabulary: 14
   Numbers: 50
   ```

5. Now try the games! 🎮

---

## Troubleshooting

### "Module 'Yams' not found"
- Go to **Product** → **Clean Build Folder** (Cmd+Shift+K)
- Rebuild (Cmd+B)
- If still failing, in Package Dependencies tab, click Yams package and check "Latest" version is selected

### App crashes on startup
- Check the **Console** tab at the bottom for error messages
- Make sure all files were copied correctly
- Verify MainTabView.swift exists in your project

### Preview not showing
- Make sure you're on an iOS 17+ simulator
- Close and reopen the preview canvas
- Check the Canvas menu for "Resume" option

### Git repo not found when fetching
- Use the full path: `/Users/davids/Documents/Source/git/bisaya-learning-data`
- Or use `file://` URL format
- Make sure the path has vocabulary.yaml and numbers.yaml files

---

## What's Next?

Now that you have a working app:

1. **Explore the code** - Open different game files and see how they work
2. **Customize vocabulary** - Edit the YAML files in the content repo and fetch them
3. **Add more games** - Create new game classes following the `Game` protocol
4. **Personalize UI** - Modify colors, fonts, and layouts in the View files
5. **Commit your changes** - Use git to commit any customizations

---

## Detailed File Structure Reference

After everything is set up, your project should look like:

```
language-game/
├── LanguageGame.xcodeproj/          ← Xcode project (created by Xcode)
│   └── project.pbxproj
├── LanguageGame/                     ← App target folder
│   ├── LanguageGameApp.swift         ← Main entry point
│   ├── Info.plist                    ← App configuration
│   ├── App/
│   │   └── (app-level files)
│   ├── Games/
│   │   ├── WordleGame.swift
│   │   ├── HangmanGame.swift
│   │   └── NumberQuizGame.swift
│   ├── Models/
│   │   ├── ContentModels.swift
│   │   └── GameProtocols.swift
│   ├── Services/
│   │   ├── DataManager.swift
│   │   └── GameManager.swift
│   ├── Views/
│   │   ├── MainTabView.swift
│   │   ├── HomeView.swift
│   │   ├── WordleGameView.swift
│   │   ├── HangmanGameView.swift
│   │   ├── NumberQuizGameView.swift
│   │   └── SettingsView.swift
│   └── Preview Content/
├── Sources/LanguageGame/             ← Original Swift Package (can delete if not needed)
│   └── (same structure as above)
├── Package.swift                     ← Swift Package manifest
├── README.md
├── XCODE_SETUP.md
└── .gitignore
```

---

## Tips for Success

- ✨ **Use Xcode Previews** - Open any View file and select Canvas to see live previews while editing
- 💾 **Commit regularly** - Use git to save your progress
- 🔍 **Test on simulator** - Always test on iOS 17+ simulator
- 📱 **Test on device** - Once working on simulator, try on your actual iPhone
- 🚀 **Archive for distribution** - When ready to share, Product → Archive

Good luck! 🎉
