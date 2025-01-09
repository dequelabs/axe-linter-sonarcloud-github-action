#!/bin/bash
# StatusCode 0 - No Accessibility Defects
# StatusCode 1 - axe DevTools Linter Detected Accessibility Defects
# StatusCode 2 - Execution problem, or axe DevTools Linter unavailable.

echo "axe DevTools Linter Starting $(date)"
echo "This job runs axe Linter scan on all the files staged for the merge process. It will only run when a merge branch process is started"

StatusCode=0
VerboseOutput="false"
OutFile="axe-linter-report.json"
TempStatusCode=0

# copy scripts and linter-connector cli to the root of the project
cp github-action-linter/* .
chmod +x axe-linter-connector-linux

if [[ -z "${AXE_LINTER_API_KEY}" ]]; then
    echo "AXE_LINTER_API_KEY must be set"
    exit 2
fi

# Get list of changed files
ChangedFiles=($(git diff-tree --no-commit-id --name-only -r $CI_COMMIT_SHA))

# File extensions to check
FileExtensions=("html" "js" "jsx" "tsx" "vue" "htm" "md" "markdown")

for file in "${ChangedFiles[@]}"; do
    # Check if the file has one of the specified extensions
    for ext in "${FileExtensions[@]}"; do
        if [[ "$file" == *.$ext ]]; then
            echo "Scanning $file"
            ./axe-linter-connector-linux \
                -s "$file" \
                -d . \
                --url="$AXE_LINTER_SERVER_URL" \
                --api-key="$AXE_LINTER_API_KEY"

            if [ ! -f "$OutFile" ]; then
                echo "$OutFile Does Not Exist"
                exit 2
            else
                if grep -q "BUG" "$OutFile"; then
                    if [ "$VerboseOutput" == "true" ]; then
                        cat "$OutFile"
                    fi

                    echo "----------------------------------------------------------------"
                    echo "axe DevTools Linter Accessibility Defect Detected: $file"
                    echo "----------------------------------------------------------------"
                    grep $OutFile
                    TempStatusCode=1
                else
                    echo "No axe DevTools Linter Bugs Detected"
                fi
            fi

            if [ "$TempStatusCode" != 0 ]; then
                StatusCode=1
            fi

            # Remove previous results
            rm -f "$OutFile"

            break
        fi
    done
done

if [ "$StatusCode" != "0" ]; then
    echo "Merge Request Failed due to Accessibility Issues"
fi
exit "$StatusCode"