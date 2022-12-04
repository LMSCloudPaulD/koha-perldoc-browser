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

# Define a bash function to handle the iteration over the files in the docs directory and its subdirectories
iterate_files() {
    # Iterate over all files and directories in the docs directory recursively
    find "$SCRIPT_PATH/docs" -type f | while read -r file; do
        # If the file is an HTML file
        if [[ $file == *.html ]]; then
            # Use the dirname command to extract the directory name from the file path
            # Use the realpath command to convert the relative path to a canonical path
            css_path=$(realpath --canonicalize-missing --relative-to="$(dirname "$file")" "$SCRIPT_PATH/sub.css")

            # Use the awk command to add the canonical path to the href attribute of the link tag
            # Use the '{ print }' action to print each line of the file
            # Use the '\n' string to add a newline character
            # Use the 'ORS' variable to specify the output record separator
            # Use the 'FILENAME' variable to specify the name of the temporary file
            awk '{ print } /<head>/ { print "\n<link rel=\"stylesheet\" href=\"'"$css_path"'\">" }' ORS="\n" "$file" > "$file.tmp"

            # Use the mv command to replace the original file with the temporary file
            mv "$file.tmp" "$file"
        fi
    done
}

# Check if the host OS is M1 macOS
if [ "$(uname -p)" = "arm" ]; then
    # Check if gsed is installed
    if ! command -v gsed >/dev/null; then
        # Show the user how to install gsed
        echo "gsed is not installed. Please run 'brew install gnu-sed' to install it and then try again."
        exit 1
    fi

    # Use gsed to insert the CSS and JS into the index.html file
    gsed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"

    # Call the iterate_files function with gsed as an argument
    iterate_files gsed
else
    # Use sed to insert the CSS and JS into the index.html file
    sed -i "s/^<\/head>/<link rel=\"stylesheet\" href=\"main.css\"><script defer src=\"kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html"

    # Call the iterate_files function with sed as an argument
    iterate_files sed
fi

# Add, commit, and push the changes to the repository
git add . || exit 1
git commit -m "Pull updates | $DATE" || exit 1
git push origin main || exit 1
