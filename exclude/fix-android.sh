#!/bin/bash

# 1. Clean out the duplicate and broken folder setups
rm -rf ~/Android/Sdk/cmdline-tools/latest-2
rm -rf ~/Android/Sdk/cmdline-tools/latest

# 2. Re-create a clean 'latest' directory
mkdir -p ~/Android/Sdk/cmdline-tools/latest
cd ~/Android/Sdk/cmdline-tools/latest

# 3. Download the clean standalone commandline tools bundle
curl -o tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

# 4. Unzip the bundle and remove the zip archive
unzip tools.zip
rm tools.zip

# 5. Correct the layout so the binaries sit directly inside the 'latest' folder
mv cmdline-tools/* .
rm -rf cmdline-tools

# 6. Run sdkmanager cleanly to update platform tools without folder duplication
./bin/sdkmanager --sdk_root=$HOME/Android/Sdk "platform-tools"
