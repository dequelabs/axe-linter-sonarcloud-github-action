#!/bin/bash
# StatusCode 0 - No Accessibility Defects
# StatusCode 1 - axe DevTools Linter Detected Accessibility Defects
# StatusCode 2 - Execution problem, or axe DevTools Linter unavailable.

echo "axe DevTools Linter Starting $(date)"

# Configure outfile: output in Generic Issue Import Format for SonarQube in execution directory.

OutFile="axe-linter-report.json"

# Remove previous results
#rm $OutFile

# execute axe-linter-connector
./axe-linter-connector-linux --api-key ${AXE_LINTER_API_KEY} --url ${AXE_LINTER_SERVER_URL} -s . -d .

echo "Checking for Results $(date)"

#pwd
#ls -la
#ls -la github-action-linter
cat "$OutFile" 

if [ ! -f "$OutFile" ];
   then
     echo "$OutFile Does Not Exit"
     exit 2

   elif cat "$OutFile" | grep -q "BUG"; then
      echo "axe DevTools Linter Accessibility Defect Detected"
      exit 1 #change this from 1 to 0 for SonarQube to run
   else
     echo "No axe DevTools Linter Bugs Detected"
fi
exit 0