# CmdSwitch

A macOS menu bar application that allows you to switch input sources (keyboard layouts and input methods) by pressing the left or right Command key alone.

## Features

- **Quick Input Source Switching**: Switch between different input sources by pressing the left or right Command key alone
- **Customizable Key Mapping**: Assign different input sources to left and right Command keys
- **Menu Bar Interface**: Easy access to settings through the menu bar
- **Persistent Configuration**: Settings are saved automatically and restored on app launch
- **Support for Multiple Input Sources**: Works with any keyboard layout or input method installed on your Mac

## Use Case

Perfect for bilingual users who frequently switch between different keyboard layouts or input methods (e.g., switching between English and Japanese input). Instead of using traditional keyboard shortcuts like `Ctrl+Space` or `Cmd+Space`, you can switch input sources with a single Command key press.

## How It Works

1. Press **only** the left Command key (without any other keys) → Switches to the input source assigned to the left Command key
2. Press **only** the right Command key (without any other keys) → Switches to the input source assigned to the right Command key
3. Using Command key with other keys (e.g., `Cmd+C`, `Cmd+V`) works normally as keyboard shortcuts

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later (for development)

## Installation

### From Source

1. Clone this repository:

```bash
git clone https://github.com/dongri/cmd-switch.git
cd cmd-switch
```

2. Open the project in Xcode:

```bash
open CmdSwitch.xcodeproj
```

3. Build and run the project in Xcode (Cmd+R)

4. Grant accessibility permissions when prompted (required for monitoring keyboard events)

## Setup

1. Launch CmdSwitch
2. Click the app icon in the menu bar
3. Select input sources for left and right Command keys from the dropdown menus
4. The app will automatically save your preferences

## Permissions

This app requires **Accessibility** permissions to monitor keyboard events. When you first launch the app, macOS will prompt you to grant these permissions in System Settings > Privacy & Security > Accessibility.

## Development

### Project Structure

```
CmdSwitch/
├── CmdSwitchApp.swift         # App entry point and menu bar setup
├── AppDelegate.swift          # Event monitoring and input source switching logic
├── ContentView.swift          # Settings UI
├── InputSourceManager.swift   # Input source management and state handling
└── Assets.xcassets/           # App icons and assets
```

### Key Components

- **CmdSwitchApp**: Main app structure using SwiftUI's `MenuBarExtra` for menu bar integration
- **AppDelegate**: Handles keyboard event monitoring using CGEvent tap, detects Command key presses, and triggers input source switching
- **InputSourceManager**: Manages available input sources, user preferences, and switching logic using Carbon's Text Input Source Services API
- **ContentView**: Provides the UI for selecting input sources for each Command key

### Technologies Used

- **SwiftUI**: For the user interface
- **AppKit**: For macOS integration and menu bar functionality
- **Carbon Framework**: For Text Input Source Services (TIS) API
- **Core Graphics**: For event tap and keyboard monitoring
- **Accessibility API**: For system-level keyboard event monitoring

### Building

1. Open `CmdSwitch.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build the project (Cmd+B)
4. Run the app (Cmd+R)

### How Event Monitoring Works

The app uses `CGEvent.tapCreate` to monitor keyboard events at the system level:

1. **Flags Changed Events**: Detects when Command keys are pressed or released
2. **Key Down Events**: Tracks if other keys are pressed while Command key is held
3. **Single Key Detection**: Switches input source only when Command key is pressed and released without other keys

### Input Source Switching

The app supports multiple methods for switching input sources:

- **Japanese Input**: Uses keyCode 104 (Kana key)
- **English Input**: Uses keyCode 102 (Eisu key)
- **Other Input Sources**: Uses `TISSelectInputSource` API

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Created by [Dongri Jin](https://github.com/dongri)
