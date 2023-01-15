#!/bin/bash

folder=($(jq -r '.name' 'info.json'))
version=($(jq -r '.version' 'info.json'))

cd ..

rm "../${folder}_${version}.zip"

zip -r "../${folder}_${version}.zip" "${folder}" -x "*/scripts/*" -x "*/.vscode/**\*" -x "*/changelog_template.txt" -x "*.git*" -x "*/\.*" -x "*/TODO_list.txt"
