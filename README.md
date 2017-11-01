# Iwr-tests (Invoke-WebRequest - tests)
PowerShell script to make assertions on Invoke-WebRequest results.

# Installation
```posh
Install-Script -Name iwr-tests -Scope CurrentUser
```

# Usage
```posh
$ErrorActionPreference = 'stop'

$result = Invoke-WebRequest -Uri https://www.powershellgallery.com/ -UseBasicParsing

$result `
	| Should ${function:HaveStatusCode} 200 `
 	| Should ${function:HaveResponseHeader} 'Content-Type' 'text/html;' `
 	| Should ${function:HaveContentThatMatches} 'Welcome\sto\sthe\sPowerShell\sGallery' `
 	| out-null
```
