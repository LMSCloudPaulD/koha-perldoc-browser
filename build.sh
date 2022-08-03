#!/bin/sh

perl -MPod::Simple::HTMLBatch -e Pod::Simple::HTMLBatch::go Koha docs

# insert stylesheet into index.html
LINK='<link rel="stylesheet" href="../main.css">'

# insert js into index.html
SCRIPT='<script src="../kohaPerldoc.js"></script>'



