# React Native Dev Environment with mise

Setup a mobile application development environment for React Native / Expo
by using the same developer tools on multiple developer machines.

## Prerequisites

- brew
- Xcode with command line tools (for iOS on macOS)
- Android Studio and SDK (for Android)

## Setup with mise

### 1. Install mise and cocoapods

brew install mise
brew install ruby@3.4
brew install cocoapods

### 2. Install toolchain

```
mise install
```

### 3. Activate mise in your shell

```
eval "$(mise activate zsh)"
```

To make this permanent, add to your ~/.zshrc:
```
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

### 4. Install dependencies

```
mise run install
```

### 5. Install platform SDKs

- iOS: Install Xcode and Xcode Command Line Tools from App Store
- Android: Install Android Studio and Android SDK from Website

### 6. CocoaPods (iOS)

```
mise run pods-install
```

## Running the application

### 1. Install JS dependencies

```
bun install
```

### 2. Prebuild (iOS or Android)

```
bun run expo-prebuild:ios
bun run expo-prebuild:android
```

### 3. Run on iOS

```
bun run expo-run:ios
```

### 4. Run on Android

```
bun run expo-run:android
```