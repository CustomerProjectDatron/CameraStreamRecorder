#!/bin/bash

# Eingabe des Projektnamens
read -p "Enter your project name: " project_name

# Ordnernamen anpassen
find . -depth -name "*NextStreamRecorder*" | while read path; do
  new_path=$(echo "$path" | sed "s/NextStreamRecorder/$project_name/g")
  mv "$path" "$new_path"
done

# Platzhalter in Dateien ersetzen
find . -type f -exec sed -i "s/NextStreamRecorder/$project_name/g" {} +

echo "Template has been customized for project: $project_name"


