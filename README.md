# Dotfiles

This repository contains my dotfiles, which are the config files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

- **Terminals**: 
  - [Warp](https://www.warp.dev/) - Rust-based terminal with AI features (primary)
  - [WezTerm](https://wezfurlong.org/wezterm/index.html) - GPU-accelerated terminal (fallback/alternative)
- **Shell**: Zsh with enhanced configuration including system identification and environment-specific setups
- **Shell Prompt**: [Starship](https://starship.rs/) - Cross-shell prompt for astronauts
- **Window Management**: [AeroSpace](https://github.com/nikitabobko/AeroSpace) - Tiling window manager for macOS
- **Status Bar**: [SketchyBar](https://felixkratz.github.io/SketchyBar/) - Highly customizable macOS status bar with:
  - Workspace indicators with app icons
  - System monitoring (CPU, battery, volume)
  - VPN status tracking with geolocation
  - Window management controls
- **Window Highlighting**: [JankyBorders](https://github.com/FelixKratz/JankyBorders) - Highlights the focused window
- **Development**: 
  - [Claude Code](https://www.anthropic.com/claude) - AI-powered coding assistant
  - Standard [Vim](https://www.vim.org/) configuration for maximum portability
  - Git completion and enhanced Git workflow
- **Cloud & DevOps**: AWS CLI with environment-specific configurations (personal/work separation)

## Features

- **Environment Detection**: Automatic system identification for work/personal environment separation
- **AWS Integration**: Separate AWS configurations for work and personal accounts
- **VPN Monitoring**: Real-time VPN status with geolocation caching
- **Application Icons**: Custom icon mapping system for 200+ applications in SketchyBar
- **Modular Configuration**: Clean separation of concerns with individual config files
- **Smart Workspace Management**: AeroSpace integration with SketchyBar for seamless workflow

## Setup

To set up these dotfiles on your system, run:

```bash
./install.sh
```

The installer will:
1. Install prerequisites (Xcode CLI tools, Homebrew)
2. Install applications and tools via Homebrew
3. Create symbolic links for all configuration files
4. Apply macOS system defaults

Follow the on-screen prompts to customize the installation.

## Uninstalling

If you ever want to remove the symlinks created by the installation script, you can use the provided symlinks removal script:

To delete all symlinks created by the installation script, run:

```bash
./scripts/symlinks.sh --delete
```

This will remove the symlinks but will not delete the actual configuration files, allowing you to easily revert to your previous configuration if needed.

## Configuration Structure

```
├── aerospace/          # AeroSpace window manager config
├── dependencies/       # External dependencies (sketchybar-app-font)
├── homebrew/          # Homebrew package definitions
├── iterm/             # iTerm2 profiles and preferences
├── scripts/           # Installation and utility scripts
├── sketchybar/        # SketchyBar configuration and plugins
├── starship/          # Starship prompt configuration
├── vim/               # Vim configuration
├── wezterm/           # WezTerm configuration (legacy)
├── zsh/               # Zsh configuration with environment separation
└── symlinks.conf      # Symbolic link definitions
```

## Key Components

### SketchyBar Plugins
- **Aerospace Integration**: Workspace switching and window management
- **System Monitoring**: Battery, volume, clock, CPU usage
- **Network**: VPN status with geolocation and caching
- **Application Tracking**: Shows running apps with custom icons

### Environment Management
- **System Identification**: Automatic detection of work/personal environments
- **AWS Configurations**: Separate setups for different AWS accounts
- **Git Completion**: Enhanced Git workflow with autocompletion

## Adding New Dotfiles and Software

### Dotfiles

1. Place your dotfile in the appropriate directory within the repository
2. Update the `symlinks.conf` file to include the symlink mapping
3. Test the symlink creation with `./scripts/symlinks.sh --create`

### Software Installation

Software is managed via Homebrew:
1. Add formulas/casks to `homebrew/Brewfile`
2. Run `./scripts/brew-install-custom.sh` or the full installer
3. For custom versions, place Ruby scripts in `homebrew/custom-casks/` or `homebrew/custom-formulae/`
