# Xcode Project Setup - Visual Checklist

## 📋 Complete Step-by-Step Checklist

### Phase 1: Create Xcode Project (3 minutes)

- [ ] **Step 1:** Open Xcode
  
- [ ] **Step 2:** File → New → Project

- [ ] **Step 3:** Select **iOS** → **App** template → Click **Next**

- [ ] **Step 4:** Fill in project settings:
  ```
  Product Name:        LanguageGame
  Team:                None
  Organization ID:     com.bisaya
  Bundle Identifier:   (auto-fills)
  Interface:           SwiftUI
  Language:            Swift
  Core Data:           ☐ (unchecked)
  Tests:               ☐ (unchecked)
  ```

- [ ] **Step 5:** Click **Next** → Save to: `/Users/davids/Documents/Source/git/language-game`

- [ ] **Step 6:** Make sure "Create Git repository" is **unchecked** (we already have git)

- [ ] **Step 7:** Click **Create** and wait for indexing

### Phase 2: Add Code Files (2 minutes)

- [ ] **Step 8:** In Xcode left sidebar, expand **LanguageGame** folder

- [ ] **Step 9:** Right-click the **LanguageGame** folder → **Add Files to "LanguageGame"**

- [ ] **Step 10:** Navigate to and select folders from `Sources/LanguageGame/`:
  - [ ] App
  - [ ] Games
  - [ ] Models
  - [ ] Services
  - [ ] Views
  - [ ] Utilities (if present)

- [ ] **Step 11:** Verify dialog settings:
  ```
  ✅ Copy items if needed
  ✅ Create groups
  ✅ Add to targets: LanguageGame
  ```

- [ ] **Step 12:** Click **Add** and wait for indexing

### Phase 3: Configure Dependencies (1 minute)

- [ ] **Step 13:** In Xcode, click the **LanguageGame** project in the left sidebar

- [ ] **Step 14:** Go to **Package Dependencies** tab (next to "Build Settings")

- [ ] **Step 15:** Click **+** to add a package

- [ ] **Step 16:** Enter URL: `https://github.com/jpsim/Yams.git`

- [ ] **Step 17:** Version: **5.0.0** or later → **Add Package**

- [ ] **Step 18:** Select target: **LanguageGame** → **Add Package**

- [ ] **Step 19:** Wait for resolution (1-2 minutes)

### Phase 4: Fix App Entry Point (30 seconds)

- [ ] **Step 20:** Find **LanguageGameApp.swift** in left sidebar

- [ ] **Step 21:** Delete the default content

- [ ] **Step 22:** Paste this code:
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

- [ ] **Step 23:** Press **Cmd+S** to save

### Phase 5: Build & Test (3 minutes)

- [ ] **Step 24:** Select simulator dropdown at top (or press Cmd+Shift+O):
  - Choose **iPhone 15** or later
  - Wait for simulator to launch

- [ ] **Step 25:** Press **Cmd+R** to build and run
  - First build takes 2-3 minutes ☕

- [ ] **Step 26:** App should launch showing **Home** tab

### Phase 6: Configure App (1 minute)

- [ ] **Step 27:** Tap **Settings** tab (⚙️ icon)

- [ ] **Step 28:** Enter:
  - Student Name: (your name)
  - Repository URL: `/Users/davids/Documents/Source/git/bisaya-learning-data`

- [ ] **Step 29:** Tap **Fetch from Repository**

- [ ] **Step 30:** ✅ Verify:
  ```
  Data loaded successfully!
  Vocabulary: 14
  Numbers: 50
  ```

### Phase 7: Play Games 🎮

- [ ] **Step 31:** Go to **Wordle** tab → **Start guessing letters!**

- [ ] **Step 32:** Try **Hangman** tab → **Guess before the drawing completes**

- [ ] **Step 33:** Try **Numbers** tab → **Match Bisaya ↔ numeric**

- [ ] **Step 34:** Go back to **Home** → **See your scores**

---

## ⏱️ Total Time Expected

- First time: **10-15 minutes** (mostly waiting for builds/downloads)
- Key waiting points:
  - Xcode indexing after project creation: 1-2 min
  - Package dependency resolution: 1-2 min
  - First build compilation: 2-3 min

---

## 🆘 If Something Goes Wrong

### Common Issues and Fixes

**"Module 'Yams' not found"**
```bash
# In Xcode terminal:
Cmd+Shift+K  (Clean build folder)
Cmd+B        (Rebuild)
```

**Preview Canvas not showing**
- Check Canvas menu → Resume
- Make sure you selected iOS 17+ simulator
- Close and reopen the preview

**App crashes on startup**
- Open **View** → **Debug Area** → **Show Console**
- Look for red error messages
- Common cause: Files not copied correctly (check left sidebar for all files)

**"Cannot find file" errors**
- Make sure all folders were added in Step 10-12
- Files should show in left sidebar indented under LanguageGame target

**Git shows "modified" after setup**
- This is normal - Xcode modified some Swift files
- You can commit these: `git add -A && git commit -m "Add Xcode project and finish setup"`

---

## ✨ What You'll Have When Done

After completing all steps:

✅ Fully functional iOS app in Xcode  
✅ All 3 games working (Wordle, Hangman, Number Quiz)  
✅ Settings to configure data source  
✅ Progress tracking on Home screen  
✅ Ready to customize and extend  

---

## 📚 Documentation Reference

| File | Purpose |
|------|---------|
| **SETUP_COMPLETE.md** | Overview of what you have |
| **QUICK_START.md** | Same steps as this checklist, but more detailed |
| **XCODE_SETUP.md** | Advanced setup options |
| **README.md** | Project architecture and features |

---

## 🚀 You're Ready!

Start at **Step 1** above and follow the checkboxes!

Need more details? Open **QUICK_START.md** for the expanded version of these steps.

Good luck! 🎉
