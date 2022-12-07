# Koha Perldoc Browser
The Koha Documentation Generator is a tool for generating documentation for the [Koha open-source library management system](https://koha-community.org/). The documentation is generated from the Koha source code using [Pod::Simple::HTMLBatch](https://metacpan.org/pod/Pod::Simple::HTMLBatch).

**Note:** This project is under development and is not yet ready for production use. Pull requests are always welcome.

## Features
* Generates HTML documentation from Koha source code
* Adds a search bar for full-text search
* Adds a navigation panel for jumping to subheadings
* Adds a "Back to Top" button for scrolling back to the top of the page
* Adds a customizable stylesheet (main.css)

## Usage
To generate the Koha documentation, first clone this repository and change into the directory:

```bash
git clone https://github.com/Koha-Community/Koha-Documentation-Generator.git
cd Koha-Documentation-Generator
Next, run the build.sh script:
```

```bash
./build.sh
This will clone the Koha repository, generate the documentation, and apply the styles and scripts. The generated documentation will be placed in the docs directory
```

## GitHub Action

The build_docs_update.yml file in the .github/workflows directory defines a GitHub Action that automatically generates the Koha documentation and pushes the changes to the main branch of this repository every six hours. This allows the documentation to be hosted on GitHub Pages at https://lmscloudpauld.github.io/koha-perldoc-browser/.

The Action runs the build.sh script and pushes the generated documentation to the main branch. It also sets git config options and uses the actions/cache action to cache the Koha repository to speed up subsequent runs of the Action.
