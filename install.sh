#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites.sh
. scripts/brew-install-custom.sh
. scripts/symlinks.sh

echo "Initializing git submodules..."
git submodule update --init --recursive

info "Dotfiles intallation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    install_xcode
    install_homebrew

    printf "\n"
    info "===================="
    info "Apps"
    info "===================="

    install_custom_formulae
    install_custom_casks
    run_brew_bundle

    echo "Building sketchybar-app-font..."
    cd dependencies/sketchybar-app-font
    if [ -f "package.json" ]; then
        npm install
        npm run build:install -- ../../sketchybar/plugins/icon_map_fn.sh
    fi
    cd ../..
fi

printf "\n"
info "===================="
info "OSX System Defaults"
info "===================="

register_keyboard_shortcuts
apply_osx_system_defaults

printf "\n"
info "===================="
info "Terminal"
info "===================="

info "Adding .hushlogin file to suppress 'last login' message in terminal..."
touch ~/.hushlogin

printf "\n"
info "===================="
info "Symbolic Links"
info "===================="

chmod +x ./scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete --include-files
fi
./scripts/symlinks.sh --create

printf "\n"
info "===================="
info "Git Hooks"
info "===================="

if [[ -f ".githooks/pre-commit" ]]; then
    chmod +x ./.githooks/pre-commit
    if [[ -f "./.githooks/sync-encrypted-envs.sh" ]]; then
        chmod +x ./.githooks/sync-encrypted-envs.sh
    fi
    git config --local core.hooksPath .githooks
    info "Configured git hooks path to .githooks"
else
    warning "Skipped git hooks setup: .githooks/pre-commit not found"
fi

success "Dotfiles set up successfully."
