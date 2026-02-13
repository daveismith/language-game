# Bisaya Language Learning Game

An iOS app to help learners practice Bisaya through interactive mini-games. Features vocabulary building and number recognition games powered by tutor-managed content repositories.

## Features

- **Wordle-Style Game** - Guess letters to find Bisaya vocabulary words
- **Hangman** - Classic hangman game with Bisaya vocabulary
- **Number Quiz** - Learn numbers with bidirectional number↔word matching
- **Tutor-Managed Content** - Connect to a content repository (git repo) that tutors can maintain per student
- **Progress Tracking** - Track your game scores and attempts
- **Offline Play** - Games work with cached content when offline

## Architecture

### Project Structure

```
Sources/LanguageGame/
├── App/                    # Main app entry point
├── Games/                  # Game implementations (Wordle, Hangman, NumberQuiz)
├── Models/                 # Game and content models
├── Services/               # DataManager and GameManager
├── Views/                  # SwiftUI views for all screens
├── Settings/               # Settings and profile management
└── Utilities/              # Helper functions
```

### Key Design Patterns

1. **Game Protocol** - All games conform to a `Game` protocol, making it easy to add new games:
   ```swift
   protocol Game {
       func startNewGame() -> GameState
       func getScore() -> GameScore
       func reset()
   }
   ```

2. **Data Management** - `DataManager` handles fetching YAML content from git repositories and caching locally

3. **Observer Pattern** - Uses SwiftUI's `@StateObject` and `@EnvironmentObject` for state management

## Getting Started

### Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Quick Setup (5 minutes)

**[👉 Follow the QUICK_START.md guide](./QUICK_START.md)** for step-by-step instructions to:
1. Create an Xcode iOS app project
2. Add the Yams package dependency
3. Copy source files into the app target
4. Build and run the app

### For Detailed Setup Instructions

See [XCODE_SETUP.md](./XCODE_SETUP.md) for alternative setup approaches and troubleshooting.

### Configuration

1. Launch the app and go to Settings
2. Enter your student name
3. Enter the URL to your data repository (see Data Repository section below)
4. Tap "Fetch from Repository" to download content
5. Start playing games!

## Data Repository

Content is managed in a separate git repository. See [bisaya-learning-data](../bisaya-learning-data) for the content structure and how tutors can manage it.

### Example Content Repository URLs

- **GitHub Public**: `https://github.com/username/bisaya-learning-data`
- **GitHub with SSH**: `git@github.com:username/bisaya-learning-data.git`

The app will automatically clone or pull the latest content from the provided URL.

## Game Descriptions

### Wordle
- Guess letters one at a time to reveal the Bisaya word
- 6 wrong guesses allowed
- 2 hints available per game
- Progressive difficulty levels

### Hangman
- Guess letters before completing the hangman drawing
- 6 wrong guesses allowed
- 1 hint available per game
- Visual feedback on hangman progress

### Number Quiz
- Master Bisaya numbers (0-100)
- Two modes: number→word or word→number
- Instant feedback on answers
- Helps build number recognition

## Adding New Games

To add a new game:

1. Create a new Swift file in `Games/` directory
2. Implement the `Game` protocol
3. Create a corresponding view in `Views/`
4. Add a tab to `MainTabView.swift`

Example:

```swift
class MyNewGame: Game {
    let id = "myNewGame"
    let name = "My Game"
    let description = "Game description"
    
    // ... implement required protocol methods
}
```

## Technologies Used

- **SwiftUI** - User interface framework
- **Yams** - YAML parsing for content files
- **Git** - Content version control integration
- **UserDefaults** - Player progress persistence

## Content Management

Content files are YAML-formatted and stored in a separate repository:
- `vocabulary.yaml` - Bisaya vocabulary with translations
- `numbers.yaml` - Bisaya numbers
- `games/*.yaml` - Game-specific configurations

Tutors can fork the content repository and customize it for each student.

## Player Progress

- Game scores and attempts are saved locally
- Statistics are displayed in the Home view
- Recent games are shown in the history
- All data persists between app launches

## Future Enhancements

- Cloud sync for progress across devices
- More games (Flashcards, Sentence Builder, etc.)
- Audio pronunciation support
- Spaced repetition algorithm
- Leaderboards
- Custom game configurations per student

## Troubleshooting

### Content not loading?
- Verify the repository URL is correct and accessible
- Check that vocabulary.yaml and numbers.yaml exist in the repository
- Ensure the app has network access

### Git clone issues?
- Make sure the repository is public or you have access credentials
- Try using HTTPS URLs instead of SSH if having permission issues

## Contributing

This is a personal learning project. Feel free to fork and customize for your own language learning!

## License

MIT

## Plan: iOS Bisaya Learning Game App
TL;DR: Create a SwiftUI iOS app with a game protocol-based architecture to easily add new games. Games pull content from a separate YAML-based git repository that tutors can configure per student. This separates app code from content, lets tutors manage vocabulary without touching code, and makes the codebase extensible for future games.

### Key Decisions Made:

- Framework: SwiftUI for clean, modern architecture
- Data: Separate git repository with YAML files (tutor maintains per-student repos via app settings)
- Games: All three (Wordle, Hangman, Number Quiz) in MVP
- Extensibility: Protocol-based game system for easy future additions

### Steps

1. Set up the Content Data Repository (separate from iOS app repo)

Create /bisaya-learning-data repository with:
vocabulary.yaml - List of Bisaya words with English translations and part of speech
numbers.yaml - Numbers 1-100+ with Bisaya written forms
games/wordle-config.yaml - Game settings (word difficulty, hints, etc.)
games/hangman-config.yaml - Configuration for hangman
.gitignore to exclude any sensitive data
Document how tutors fork/maintain their own instance for students
Initialize iOS App Project Structure

Create new Xcode project with SwiftUI
Organize folders: Games/, Data/, Models/, Services/, Views/, Settings/
Add Package.swift or Podfile for dependencies (e.g., YAML parsing library like Yams)
Build Core Data & Game Architecture

Create Game protocol with required properties/methods (play(), getScore(), etc.)
Create GameContent models to parse YAML (e.g., Vocabulary, Number)
Build DataFetcher service to clone/pull from configured git repo URL
Build SettingsManager to store/manage tutor's data repo URL per student profile
Create local caching strategy (store fetched YAML locally to avoid constant pulls)
Implement Game Screen Architecture

Create GameTabView that hosts all games as tabs
Build GameContainerView protocol that wraps individual game views
Each game gets its own folder: Games/WorkdleGame/, Games/HangmanGame/, Games/NumberQuizGame/
Build the Three Games

Wordle Game: Random word selection → player guesses letters → reveals positions → tracks attempts
Hangman Game: Similar mechanics but with drawn hangman stages and word masking
Number Quiz: Randomizes between two modes: show number → type Bisaya form, or show Bisaya → type digit
Each implements the Game protocol for consistent scoring/UI integration
Create Settings & Profile Management

Add SettingsView where tutor enters/updates data repository URL
Allow multiple student profiles with different repo URLs
Add refresh button to force re-pull content from selected repo
Display current vocabulary/content count as validation
Build Main Navigation & UI Shell

Home screen showing available games and current student profile
Navigation between settings and game tabs
Progress/stats view (optional for MVP but easy to add later)
Testing Strategy

Unit tests for YAML parsing and data models
Mock data repo for local testing without live git calls
SwiftUI preview tests for each game component
Verification

Clone the data repo, configure its URL in the app, tap refresh → vocabulary loads successfully
Play each of the three games start-to-finish → score calculates correctly
Add a new game protocol implementation → appears in tabs with minimal changes to main app
Change data repo URL in settings → app fetches from new source
Offline mode: cached data should allow gameplay with old data if git pull fails
Architecture Benefits for Future Extensibility

This design lets you add game #4, #5, etc. by:

Adding game config to YAML repo
Creating new struct implementing Game protocol
Adding it to the tab navigation
No changes to core app infrastructure needed.
Does this align with your vision? Any adjustments to the scope, tech stack, or data structure?

