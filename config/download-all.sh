#!/bin/bash
cd /tmp
count=0
while IFS= read -r url || [ -n "$url" ]; do
    test -z "$url" && continue
    filename=$(basename "$url")
    dept=$(echo "$filename" | sed 's/adresses-//;s/.csv.gz//')
    count=$((count + 1))
    echo "[$count] $dept"
    curl -L -s -o "$filename" "$url"
    if [ -f "$filename" ]; then
        gunzip -f "$filename"
        if [ -f "${filename%.gz}" ]; then
            size=$(du -h "${filename%.gz}" | cut -f1)
            lines=$(wc -l < "${filename%.gz}")
            echo "  OK: $size, $lines lignes"
        fi
    fi
done < /usr/local/bin/urls.txt
echo "Termine: $count fichiers"
