# Development tooling for the Hugo blog (Blowfish theme requires Extended build).
# Comments in English per project convention.

HUGO_VERSION ?= 0.160.1
# Pin a full Go release (see https://go.dev/dl/). go.mod requires >= 1.21.
GO_VERSION ?= 1.22.12
# Minimum Go toolchain for Hugo Modules (major.minor.patch for sort -V).
GO_MIN ?= 1.21.0
GO_ROOT := $(HOME)/.local/go
INSTALL_DIR ?= $(HOME)/.local/bin
HUGO ?= hugo

# Extra flags for `make dev` (e.g. `make dev HUGO_DEV_FLAGS="-D --bind 0.0.0.0"` on WSL).
HUGO_DEV_FLAGS ?= -D

# Local toolchain first (recipes use explicit PATH=; do not export from Make — breaks some environments).
TOOL_PATH = $(GO_ROOT)/bin:$(INSTALL_DIR)

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Linux)
  ifeq ($(UNAME_M),x86_64)
    HUGO_OS_ARCH := linux-amd64
  else ifeq ($(UNAME_M),aarch64)
    HUGO_OS_ARCH := linux-arm64
  else
    $(error Unsupported Linux architecture: $(UNAME_M). Install Hugo Extended manually.)
  endif
else ifeq ($(UNAME_S),Darwin)
  ifeq ($(UNAME_M),x86_64)
    HUGO_OS_ARCH := darwin-amd64
  else ifeq ($(UNAME_M),arm64)
    HUGO_OS_ARCH := darwin-arm64
  else
    $(error Unsupported macOS architecture: $(UNAME_M). Install Hugo Extended manually.)
  endif
else
  $(error Unsupported OS: $(UNAME_S). Use https://gohugo.io/installation/ or install Hugo Extended manually.)
endif

HUGO_ARCHIVE := hugo_extended_$(HUGO_VERSION)_$(HUGO_OS_ARCH).tar.gz
HUGO_URL := https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_ARCHIVE)

.PHONY: help setup check-go install-go install-hugo mod-download dev dev-wsl build clean

help:
	@echo "Targets:"
	@echo "  make setup         - install-go, install Hugo Extended $(HUGO_VERSION), go mod download"
	@echo "  make install-go    - Idempotent Go $(GO_VERSION) under $(GO_ROOT) (skips if Go $(GO_MIN)+ exists)"
	@echo "  make check-go      - Verify Go $(GO_MIN)+ is available (required for Hugo Modules)"
	@echo "  make install-hugo  - Download and install Hugo Extended only"
	@echo "  make mod-download  - Run go mod download (theme modules; Hugo has no mod download subcommand)"
	@echo "  make dev           - Development server with drafts (localhost:1313)"
	@echo "  make dev-wsl       - Same as dev but bound to 0.0.0.0 (easier from Windows browser on WSL2)"
	@echo "  make build         - Production build with minify (output: public/)"
	@echo "  make clean         - Remove generated public/ directory"
	@echo ""
	@echo "Variables: HUGO_VERSION, GO_VERSION, GO_MIN, GO_ROOT, INSTALL_DIR, HUGO, HUGO_DEV_FLAGS"

setup: install-go install-hugo mod-download
	@echo ""
	@echo "Setup finished. Open a new shell or: export PATH=\"$(TOOL_PATH):\$$PATH\""
	@PATH="$(TOOL_PATH):$$PATH" command -v hugo >/dev/null && PATH="$(TOOL_PATH):$$PATH" "$(HUGO)" version

check-go:
	@PATH="$(TOOL_PATH):$$PATH"; \
	command -v go >/dev/null 2>&1 || ( echo "Go $(GO_MIN)+ is required. Run: make install-go"; exit 1 ); \
	got=$$(go env GOVERSION | sed 's/^go//'); \
	if [ "$$(printf '%s\n' "$(GO_MIN)" "$$got" | sort -V | head -n1)" != "$(GO_MIN)" ]; then \
		echo "Go $(GO_MIN)+ is required (found go$$got). Run: make install-go"; \
		exit 1; \
	fi; \
	go version

# Idempotent: skip if $(GO_ROOT)/bin/go matches GO_VERSION, or any go >= GO_MIN on PATH.
# When installing under $(GO_ROOT), appends a marked block to the first of ~/.bashrc, ~/.profile, ~/.zshrc without the marker (or creates ~/.profile).
install-go:
	@set -e; \
	GO_ROOT="$(GO_ROOT)"; \
	GV="$(GO_VERSION)"; \
	GO_MIN="$(GO_MIN)"; \
	ARCH="$(HUGO_OS_ARCH)"; \
	GO_TAR="go$${GV}.$${ARCH}.tar.gz"; \
	URL="https://go.dev/dl/$${GO_TAR}"; \
	configure_profile() { \
		[ -x "$${GO_ROOT}/bin/go" ] || return 0; \
		MARKER="# nolram-blog: Go toolchain"; \
		for f in "$$HOME/.bashrc" "$$HOME/.profile" "$$HOME/.zshrc"; do \
			[ -f "$$f" ] || continue; \
			grep -qF "$$MARKER" "$$f" 2>/dev/null && return 0; \
		done; \
		for f in "$$HOME/.bashrc" "$$HOME/.profile" "$$HOME/.zshrc"; do \
			[ -f "$$f" ] || continue; \
			{ echo ""; echo "$$MARKER"; echo 'export GOROOT="$$HOME/.local/go"'; echo 'export PATH="$$GOROOT/bin:$$PATH"'; } >>"$$f"; \
			echo "Appended Go toolchain PATH to $$f"; \
			return 0; \
		done; \
		{ echo "$$MARKER"; echo 'export GOROOT="$$HOME/.local/go"'; echo 'export PATH="$$GOROOT/bin:$$PATH"'; } >"$$HOME/.profile"; \
		echo "Created $$HOME/.profile with Go toolchain PATH"; \
	}; \
	if [ -x "$${GO_ROOT}/bin/go" ]; then \
		installed=$$("$${GO_ROOT}/bin/go" env GOVERSION); \
		if [ "$$installed" = "go$${GV}" ]; then \
			echo "Go $${GV} already installed at $${GO_ROOT}"; \
			configure_profile; \
			exit 0; \
		fi; \
	fi; \
	PATH="$${GO_ROOT}/bin:$$PATH"; \
	if command -v go >/dev/null 2>&1; then \
		got=$$(go env GOVERSION | sed 's/^go//'); \
		if [ "$$(printf '%s\n' "$$GO_MIN" "$$got" | sort -V | head -n1)" = "$$GO_MIN" ]; then \
			echo "Go already satisfies >= $$GO_MIN ($$(go version))"; \
			exit 0; \
		fi; \
	fi; \
	echo "Downloading Go $${GV} ($${ARCH})..."; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT; \
	if command -v wget >/dev/null 2>&1; then \
		wget -q -O "$$tmpdir/$$GO_TAR" "$$URL"; \
	elif command -v curl >/dev/null 2>&1; then \
		curl -fsSL -o "$$tmpdir/$$GO_TAR" "$$URL"; \
	else \
		echo "Install wget or curl to download Go."; \
		exit 1; \
	fi; \
	mkdir -p "$$(dirname "$${GO_ROOT}")"; \
	rm -rf "$${GO_ROOT}"; \
	tar -C "$$(dirname "$${GO_ROOT}")" -xzf "$$tmpdir/$$GO_TAR"; \
	chmod +x "$${GO_ROOT}/bin/go"; \
	echo "Installed: $$("$${GO_ROOT}/bin/go" version)"; \
	configure_profile

install-hugo:
	@mkdir -p "$(INSTALL_DIR)"
	@echo "Downloading Hugo Extended $(HUGO_VERSION) for $(HUGO_OS_ARCH)..."
	@if command -v wget >/dev/null 2>&1; then \
		wget -q -O /tmp/$(HUGO_ARCHIVE) "$(HUGO_URL)"; \
	elif command -v curl >/dev/null 2>&1; then \
		curl -fsSL -o /tmp/$(HUGO_ARCHIVE) "$(HUGO_URL)"; \
	else \
		echo "Install wget or curl to download Hugo."; \
		exit 1; \
	fi
	tar -xzf /tmp/$(HUGO_ARCHIVE) -C /tmp hugo
	mv /tmp/hugo "$(INSTALL_DIR)/hugo"
	chmod +x "$(INSTALL_DIR)/hugo"
	rm -f /tmp/$(HUGO_ARCHIVE)
	@echo "Installed: $(INSTALL_DIR)/hugo"
	@"$(INSTALL_DIR)/hugo" version

mod-download: install-go
	@PATH="$(TOOL_PATH):$$PATH"; \
	command -v hugo >/dev/null 2>&1 || (echo "Run: make install-hugo"; exit 1); \
	command -v go >/dev/null 2>&1 || (echo "Go is required for modules. Run: make install-go"; exit 1); \
	go mod download

dev:
	@PATH="$(TOOL_PATH):$$PATH" "$(HUGO)" server $(HUGO_DEV_FLAGS)

# WSL2: listen on all interfaces so the site opens from the Windows host browser.
dev-wsl:
	@PATH="$(TOOL_PATH):$$PATH" "$(HUGO)" server -D --bind 0.0.0.0 --baseURL http://localhost:1313

build:
	@PATH="$(TOOL_PATH):$$PATH" "$(HUGO)" --minify

clean:
	rm -rf public
