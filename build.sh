#!/bin/bash

echo "Starting up.."

# Get the path of the script and change into that directory
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_PATH" || exit 1

# Set the repository URL and date
REPOSITORY='https://github.com/Koha-Community/Koha.git'
DATE=$(date)

echo "Globals set.."

# Change into the Koha directory
echo "Changing into Koha/ .."
cd Koha || exit 1

echo "Pulling Koha repository"

# Reset the repository to the latest version on origin/master
# and then pull the latest changes
git reset --hard origin/master || exit 1
git pull "$REPOSITORY" || exit 1

echo "Changing back into root directory.."
cd "$SCRIPT_PATH" || exit 1

# Generate the documentation
echo "Generating documentation"
perl -MPod::Simple::HTMLBatch -e Pod::Simple::HTMLBatch::go Koha docs || exit 1

# Copy the main.css and kohaPerldoc.js files to the docs directory
cp main.css docs/ || exit 1
cp kohaPerldoc.js docs/ || exit 1

# Check if the host OS is M1 macOS
if [ "$(uname -p)" = "arm64" ]; then
    # Check if gsed is installed
    if ! command -v gsed > /dev/null; then
        # Show the user how to install gsed
        echo "gsed is not installed. Please run 'brew install gnu-sed' to install it and then try again."
        exit 1
    fi
    # Use gsed to insert the CSS and JS into the index.html file
    echo "Inserting CSS & JS"
    gsed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"
else
    # Use sed to insert the CSS and JS into the index.html file
    echo "Inserting CSS & JS"
    sed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"
fi

# Add, commit, and push the changes to the repository
git add . || exit 1
git commit -m "Pull updates | $DATE" || exit 1
git push origin main || exit 1
