
<#PSScriptInfo

.VERSION 1.1

.GUID 1d93c562-6713-4503-91a4-3fce3e7a1ca8

.AUTHOR Vidar Kongsli

.COMPANYNAME Bredvid AS

.COPYRIGHT 2017

.TAGS

.LICENSEURI https://github.com/vidarkongsli/iwr-tests/blob/master/LICENSE

.PROJECTURI https://github.com/vidarkongsli/iwr-tests

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.DESCRIPTION 
 PowerShell script to make assertions on Invoke-WebRequest results 

#> 

function Should {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $result,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]$predicate,
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        $_args
    )
    process {
        $isOk, $err = & $predicate $result @_args
        if (!$isOk) {
            Write-Error $err
        }
        $result
    }
}

function HaveStatusCode {
    param($r, $expect)
    $returnedCode = $r.StatusCode -as [int]
    if (-not($returnedCode -eq $expect)) {
        $false
        "$($r.Method) $($r.ResponseUri) returned wrong status code: $returnedCode. Expected: $expect"
    }
    else {
        $true
    }
}

function HaveResponseHeader {
    param($r, $headername, $headervalue)
    if (-not($r.Headers.Keys.Contains($headername))) {
        $false
        "$($r.Method) $($r.ResponseUri) did not return a resonse header '$headername'"
    }
    else {
        $header = $r.Headers[$headername]
        if (-not($header.Contains($headervalue))) {
            $false
            "$($r.Method) $($r.ResponseUri) returned header '$headername=$header' which does not contain expected '$headervalue'"
        }
        else {
            $true
        }
    }
}

function HaveContentThatMatches {
    param($r, [regex]$pattern)
    if (-not($r.Content -match $pattern)) {
        $false
        "$($r.Method) $($r.ResponseUri) returned content that did not match $pattern"
    }
    else {
        $true
    }
}

function Invoke-Endpoint {
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $uri,
        [Parameter(Mandatory = $false)]
        $method = 'GET',
        [Parameter(Mandatory = $false)]
        $baseuri = '',
        [Parameter(Mandatory=$false)]
        [System.Net.HttpStatusCode[]] $retryStatusCodes = @([System.Net.HttpStatusCode]::ServiceUnavailable),
        [Parameter(Mandatory=$false)]
        $retryDelay = 5,
        [Parameter(Mandatory=$false)]
        $retryCount = 3,
        [Parameter(Mandatory=$false)]
        $body = $null
    )
    begin {
        $auldProgressPreference = $ProgressPreference
        $ProgressPreference = 'silentlycontinue'      
    }
    process {
        $done = $false
        $currentRetry = 0
        do {
            try {
              Write-debug "Perfroming web request to $($baseuri)$($uri)"
              Invoke-WebRequest "$baseuri$uri" -Method $method -UseBasicParsing -Body $body
              $done = $true
            }
            catch [System.Net.WebException] {
                $resp = $_.Exception.Response
                $currentRetry += 1
                $isARetryCode = $retryStatusCodes -contains $resp.StatusCode
                Write-debug "Is retry code: $isARetryCode"
                $hasRetriedEnough = $currentRetry -gt ($retryCount + 1)
                Write-debug "Has retried enough: $hasRetriedEnough"
                if ($hasRetriedEnough -or(-not($isARetryCode))) {
                    Write-debug "Returing response object"
                    $resp
                    $done = $true
                } else {
                    $sleepTime = $retryDelay*$currentRetry
                    Write-debug "Sleeping for $sleepTime seconds"
                    Start-Sleep -Seconds $sleepTime 
                }
            }
            catch {
                Write-debug "Got a generic exception. Quitting immediately"
                return $_.Exception
            }
        } while (!$done)
    }
    end {
        $ProgressPreference = $auldProgressPreference
    }
}