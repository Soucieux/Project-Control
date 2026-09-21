# Native Apple frameworks only. Publish the signed app beside this Makefile.
SHELL := /bin/zsh
SWIFT := /usr/bin/xcrun swiftc
BUILD := build
APP := $(BUILD)/Project Control.app
FINAL_APP := Project Control.app
ASSET_CATALOG := Resources/Assets.xcassets
ASSET_OUTPUT := $(BUILD)/IconAssets
ICON_FILE := $(BUILD)/ProjectControl.icns
CORE := $(wildcard Sources/Core/*.swift)
UI := $(wildcard Sources/App/*.swift)
TEST_SUPPORT := Tests/TestConstants.swift Tests/TestFixtures.swift Tests/NotesTestConstants.swift
TEST_ARGS ?=
ARCH := $(shell uname -m)
FLAGS := -swift-version 5 -parse-as-library -target $(ARCH)-apple-macos14.0 -module-cache-path $(BUILD)/ModuleCache

.PHONY: icons app check-version test test-core test-store test-notes test-version run

check-version:
	/bin/bash Scripts/check-version.sh

test-version:
	/bin/bash Tests/VersionChecks.sh

test-notes:
	@mkdir -p "$(BUILD)"
	$(SWIFT) $(FLAGS) -framework AppKit -framework SwiftUI $(CORE) Sources/App/ControlStore.swift $(TEST_SUPPORT) Tests/NotesTests.swift -o "$(BUILD)/NotesTests"
	"$(BUILD)/NotesTests"

icons:
	@mkdir -p "$(ASSET_OUTPUT)"
	/usr/bin/xcrun actool --compile "$(ASSET_OUTPUT)" --platform macosx \
		--minimum-deployment-target 14.0 --target-device mac --app-icon AppIcon \
		--output-partial-info-plist "$(ASSET_OUTPUT)/asset-info.plist" "$(ASSET_CATALOG)" >/dev/null
	cp "$(ASSET_OUTPUT)/AppIcon.icns" "$(ICON_FILE)"

app: check-version icons
	@mkdir -p "$(APP)/Contents/MacOS" "$(APP)/Contents/Resources"
	$(SWIFT) $(FLAGS) -O -framework AppKit -framework SwiftUI $(CORE) $(UI) -o "$(APP)/Contents/MacOS/ProjectControl"
	cp Resources/Info.plist "$(APP)/Contents/Info.plist"
	cp "$(ICON_FILE)" "$(APP)/Contents/Resources/ProjectControl.icns"
	/usr/bin/codesign --force --sign - "$(APP)"
	/usr/bin/codesign --verify --strict "$(APP)"
	@set -eu; \
	if [[ -e "$(FINAL_APP)" ]]; then \
		previous="$$(mktemp -d "$(BUILD)/previous.XXXXXX")"; \
		mv "$(FINAL_APP)" "$$previous/$(FINAL_APP)"; \
		if ! mv "$(APP)" "$(FINAL_APP)"; then \
			mv "$$previous/$(FINAL_APP)" "$(FINAL_APP)"; exit 1; \
		fi; \
		rm -rf "$$previous"; \
	else mv "$(APP)" "$(FINAL_APP)"; fi

test: test-core test-store test-notes test-version

test-core:
	@mkdir -p "$(BUILD)"
	$(SWIFT) $(FLAGS) $(CORE) $(TEST_SUPPORT) Tests/CoreTests.swift -o "$(BUILD)/CoreTests"
	"$(BUILD)/CoreTests" $(TEST_ARGS)

test-store:
	@mkdir -p "$(BUILD)"
	$(SWIFT) $(FLAGS) -framework AppKit -framework SwiftUI $(CORE) Sources/App/ControlStore.swift $(TEST_SUPPORT) Tests/StoreTests.swift -o "$(BUILD)/StoreTests"
	"$(BUILD)/StoreTests" $(TEST_ARGS)

run: app
	open "$(FINAL_APP)"
