#!/usr/bin/env -S nix develop --command bash

# $ nix develop
# <devshell> $ ./pull.sh

# Run this script initially (in this directory) from inside a Nix development shell.
# It will create a workspace `dev_ws` in the current directory.
# The version of `all_seaing_vehicle` is the one specified or the latest revision by default.
# Only run this script once and use `./build.sh` after.
# Dependencies will intentionally not be updated to ensure reproducibility.

# create a workspace
echo -e "\e[1mCreating a workspace for all_seaing_vehicle and dependencies in dev_ws/src\e[0m"
echo "====="
mkdir -p ./dev_ws/src
cd ./dev_ws/src
echo -e "\e[1mDone creating workspaces.\e[0m"

# use latest commit (no version tag) of ros2-keyboard
echo -e "\e[1mCloning ros2-keyboard (f1d8412)\e[0m"
echo "====="
git clone --depth 1 https://github.com/cmower/ros2-keyboard
cd ros2-keyboard
git fetch --depth 1 origin f1d84122b40cbeec05d54ce90d35c8d16b47bbad >/dev/null 2>&1
git checkout f1d84122b40cbeec05d54ce90d35c8d16b47bbad >/dev/null 2>&1
cd ..
echo -e "Done cloning ros2-keyboard."

# set script perms
cd ../..
chmod +x build.sh

echo -e "\e[1mDone fetching repositories.\e[0m"
echo -e "\e[1mUse \`./build.sh\` before running your first node.\e[0m"
