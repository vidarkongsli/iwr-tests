# Iwr-tests (Invoke-WebRequest - tests)

PowerShell script to make assertions on Invoke-WebRequest results.
![Appveyor build status](https://ci.appveyor.com/api/projects/status/github/vidarkongsli/iwr-tests)

## Installation

```posh
Install-Script -Name iwr-tests -Scope CurrentUser
```

## Usage

### Basic usage

```posh
$ErrorActionPreference = 'stop'

$result = Invoke-Endpoint -Uri https://www.powershellgallery.com/

$result `
    | Should ${function:HaveStatusCode} 200 `
    | Should ${function:HaveResponseHeader} 'Content-Type' 'text/html;' `
    | Should ${function:HaveContentThatMatches} 'Welcome\sto\sthe\sPowerShell\sGallery' `
    | out-null
```

### Advanced usage

```posh
$ErrorActionPreference = 'stop'

$result = Invoke-Endpoint `
    -Uri https://www.powershellgallery.com/ `
    -method GET `
    -retryStatusCodes ServiceUnavailable, GatewayTimeout `
    -retryCount 5 ` # Retry five times
    -retryDelay 5 # Delay for five seconds between tries

$result `
    | Should ${function:HaveStatusCode} 200 `
    | Should ${function:HaveResponseHeader} 'Content-Type' 'text/html;' `
    | Should ${function:HaveContentThatMatches} 'Welcome\sto\sthe\sPowerShell\sGallery' `
    | out-null
```
