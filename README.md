# axe Linter Connector and SonarQube Cloud Integration with GitHub Action

You will need to download a copy of the **[axe-linter-connector](https://docs.deque.com/linter/4.0.0/en/downloads)** for your runner's platform and place it in the root of your project along with the bash scripts contained here.

**[Downloads for axe DevTools Linter](https://docs.deque.com/linter/4.0.0/en/downloads)**

If using a platform other than linux you will need to update the command in the bash scripts (ie: change `axe-linter-connector-linux` to`axe-linter-connector-macos` or `axe-linter-connector-win.exe`).

**Note:** it maybe possible to deploy this scripts in other CI/CD pipelines.

## Bash Scripts

* **axe-liner-full.sh** - Lints all files in the repository
* **axe-liner-changed.sh** - Lints only changed files

## GitHub Action YML
```yml
...

      - name: Run axe Linter
        run: ${GITHUB_WORKSPACE}/axe-linter-full.sh #or axe-linter-changed.sh
        env: 
          AXE_LINTER_API_KEY: ${{ secrets.AXE_LINTER_API_KEY }}
          AXE_LINTER_SERVER_URL: https://axe-linter.deque.com/
      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        with: 
          args: > 
            -Dsonar.projectKey=<your-project-key>
            -Dsonar.organization=<your-organization>
            -Dsonar.externalIssuesReportPaths=axe-linter-report.json
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

...
```

## axe-linter-connector debugging
For additional axe-linter-connector debugging logs prepend `DEBUG=* ` to the linter-connector command in the bash script.
```
DEBUG=* axe-linter-connector -s . -d . --api-key $AXE_LINTER_API_KEY --url $AXE_LINTER_SERVER_URL
```
