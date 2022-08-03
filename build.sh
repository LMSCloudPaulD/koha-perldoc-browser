#!/bin/bash

echo "Starting up.."

SCRIPT_NAME=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT_NAME")
REPOSITORY='https://github.com/Koha-Community/Koha.git'
DATE=$(date)
# LINK='<link rel="stylesheet" href="\.\.\/main.css">'
# SCRIPT='<script src="\.\.\/kohaPerldoc\.js"><\/script>'

echo "Globals set.."

echo "$SCRIPT_PATH"

echo "Changing into Koha/ .."
cd "$SCRIPT_PATH/Koha" || exit 1

echo "Pulling Koha repository"
git reset --hard origin/master || exit 1
git pull "$REPOSITORY" || exit 1

echo "Chaning back into root directory.."
cd "$SCRIPT_PATH" || exit 1

echo "Generating documentation"
perl -MPod::Simple::HTMLBatch -e Pod::Simple::HTMLBatch::go Koha docs || exit 1

# use regular sed on Linux; macOS uses BSD sed by default and acts strange
echo "Inserting CSS & JS"
INDEX_HTML=$(gsed "s/^<\/head>/<link rel=\"stylesheet\" href=\"\.\.\/main.css\"><script src=\"\.\.\/kohaPerldoc\.js\"><\/script><\/head>/g" "$SCRIPT_PATH/docs/index.html")

echo "$INDEX_HTML" > "$SCRIPT_PATH/docs/index.html"

git add . || exit 1
git commit -m "Pull updates | $DATE" || exit 1
git push origin main || exit 1






