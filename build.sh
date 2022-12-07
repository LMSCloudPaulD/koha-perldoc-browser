#!/bin/bash

echo "Starting up.."

# Get the path of the script and change into that directory
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_PATH" || exit 1

# Set the repository URL and date
REPOSITORY='https://github.com/Koha-Community/Koha.git'
DATE=$(date)

echo "Globals set.."

# Check if the Koha directory exists
if [ ! -d "Koha" ]; then
    # Clone the Koha repository from GitHub
    git clone "$REPOSITORY"

    # Change into the Koha directory
    cd Koha || exit 1
else
    # Change into the Koha directory
    cd Koha || exit 1
fi

echo "Pulling Koha repository"

# Reset the repository to the latest version on origin/master
# and then pull the latest changes
git reset --hard origin/master || exit 1
git pull "$REPOSITORY" || exit 1

echo "Changing back into root directory.."
cd "$SCRIPT_PATH" || exit 1

# Generate the documentation
echo "Generating documentation"
perl -MPod::Simple::HTMLBatch -e 'Pod::Simple::HTMLBatch::go(css_flurry => 0, javascript_flurry => 0, @ARGV);' Koha docs || exit 1

# Copy the main.css and kohaPerldoc.js files to the docs directory
cp main.css docs/ || exit 1
cp sub.css docs/ || exit 1
cp kohaPerldoc.js docs/ || exit 1

# Check if the host OS is M1 macOS
echo "Inserting main.css and kohaPerldoc.js"
if [ "$(uname -p)" = "arm" ]; then
    # Check if gsed is installed
    if ! command -v gsed >/dev/null; then
        # Show the user how to install gsed
        echo "gsed is not installed. Please run 'brew install gnu-sed' to install it and then try again."
        exit 1
    fi

    # Use gsed to insert the CSS and JS into the index.html file
    gsed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"
else
    # Use sed to insert the CSS and JS into the index.html file
    sed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"
fi

# Use the dirname command to remove the last two directories from the file path
# Use the realpath command to convert the relative path to a canonical path
# Use the awk command to add the canonical path to the href attribute of the link tag
# Use the '{ print }' action to print each line of the file
# Use the '\n' string to add a newline character
# Use the 'ORS' variable to specify the output record separator
# Use the 'FILENAME' variable to specify the name of the temporary file
# Use the '{ print } /<head>/ { print ... }' structure to add the link tag after the <head> tag
# Use the mv command to replace the original file with the temporary file
echo "Inserting sub.css"
find "$SCRIPT_PATH/docs" -mindepth 2 -type f | while read -r file; do
    if [[ $file == *.html ]]; then
        css_path=$(realpath --canonicalize-missing --relative-to="$(dirname "$file" | xargs dirname)" "$SCRIPT_PATH/sub.css")
        awk '{ print } /<head>/ { print "\n<link rel=\"stylesheet\" href=\"'$css_path'\">" }' ORS="\n" "$file" >"$file.tmp"
        mv "$file.tmp" "$file"
    fi
done

echo "Inserting favicon"
find "$SCRIPT_PATH/docs" -mindepth 1 -type f | while read -r file; do
    if [[ $file == *.html ]]; then
        css_path=$(realpath --canonicalize-missing --relative-to="$(dirname "$file" | xargs dirname)" "$SCRIPT_PATH/sub.css")
        awk '{ print } /<head>/ { print "\n<link rel=\"icon\" href=\"data:image/svg+xml,<svg xmlns='\''http://www.w3.org/2000/svg'\'' viewBox='\''0 0 100 100'\''><text y='\''.9em'\'' font-size='\''90'\''>🍃</text></svg>\" />" }' ORS="\n" "$file" >"$file.tmp"
        mv "$file.tmp" "$file"
    fi
done

# Add, commit, and push the changes to the repository
git add . || exit 1
git commit -m "Pull updates | $DATE" || exit 1
git push origin main || exit 1
