#!/bin/bash

# Launch the ExpressCoach app in the simulator
echo "Launching ExpressCoach app in iPhone 17 Pro simulator..."

# Boot the simulator if not already booted
xcrun simctl boot "iPhone 17 Pro" 2>/dev/null || true

# Open the Simulator app
open -a Simulator

# Wait for simulator to boot
sleep 3

# Install and launch the app
xcrun simctl install "iPhone 17 Pro" ~/Library/Developer/Xcode/DerivedData/ExpressCoach-*/Build/Products/Debug-iphonesimulator/ExpressCoach.app
xcrun simctl launch "iPhone 17 Pro" com.yourcompany.ExpressCoach

echo "App launched. Check the simulator window."