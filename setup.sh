#!/usr/bin/env bash

set -Eeuo pipefail


PORT=3000
BUILD_TAGS="bindata sqlite sqlite_unlock_notify"
GITEA_BINARY="./gitea"



print_status() {
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

print_success() {
    echo "[SUCCESS] $1"
}

print_error() {
    echo "[ERROR] $1" >&2
}



handle_error() {
    local exit_code=$?
    print_error "Setup failed at line $1."
    print_error "Command: $2"
    print_error "Exit code: $exit_code"
    exit "$exit_code"
}

trap 'handle_error "$LINENO" "$BASH_COMMAND"' ERR



print_status "Checking Gitea project directory"

if [[ ! -d ".git" || ! -f "go.mod" || ! -f "Makefile" ]]; then
    print_error "This script must be run from the Gitea project root."
    print_error "Expected .git/, go.mod and Makefile."
    exit 1
fi

print_success "Gitea project directory verified."



print_status "Checking required tools"

REQUIRED_TOOLS=(
    git
    go
    node
    npm
    pnpm
    make
    uv
)

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        print_error "$tool is not installed or not available in PATH."
        exit 1
    fi

    print_success "$tool is installed."
done



print_status "Dependency versions"

echo "Git:    $(git --version)"
echo "Go:     $(go version)"
echo "Node:   $(node --version)"
echo "npm:    $(npm --version)"
echo "pnpm:   $(pnpm --version)"
echo "Make:   $(make --version | head -n 1)"
echo "uv:     $(uv --version)"


print_status "Installing Gitea dependencies"

make deps

print_success "Dependencies installed successfully."


print_status "Building Gitea from source"

TAGS="$BUILD_TAGS" make build

print_success "Gitea build completed."


print_status "Verifying Gitea binary"

if [[ ! -x "$GITEA_BINARY" ]]; then
    print_error "Gitea binary was not created successfully."
    exit 1
fi

print_success "Gitea binary found."

echo
echo "Gitea version:"
"$GITEA_BINARY" --version


print_status "Checking port $PORT"

if command -v ss >/dev/null 2>&1; then
    if ss -ltn | awk '{print $4}' | grep -Eq ":${PORT}$"; then
        print_error "Port $PORT is already in use."
        print_error "Please stop the existing service and run this script again."
        exit 1
    fi
else
    print_error "The 'ss' command is required to check port $PORT."
    exit 1
fi

print_success "Port $PORT is available."



print_status "Starting Gitea"

echo "Gitea URL: http://localhost:$PORT"
echo
echo "Press Ctrl+C to stop Gitea."
echo

"$GITEA_BINARY" web
