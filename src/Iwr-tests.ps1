
<#PSScriptInfo

.VERSION 1.0

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
    [Parameter(Mandatory, Position=1)]
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

function HaveStatusCode  {
  param($r, $expect)
  $returnedCode = $r.StatusCode -as [int]
  if (-not($returnedCode -eq $expect)) {
    $false
    "$($r.ResponseUri) returned wrong status code: $returnedCode. Expected: $expect"
  } else {
    $true
  }
}

function HaveResponseHeader {
  param($r, $headername, $headervalue)
  if (-not($r.Headers.Keys.Contains($headername))) {
    $false
    "GET $($r.ResponseUri) did not return a resonse header '$headername'"
  } else {
    $header = $r.Headers[$headername]
    if (-not($header.Contains($headervalue))) {
      $false
      "GET $($r.ResponseUri) returned header '$headername=$header' which does not contain expected '$headervalue'"
    } else {
      $true
    }
  }
}

function HaveContentThatMatches {
  param($r, [regex]$pattern)
  if (-not($r.Content -match $pattern)) {
    $false
    "GET $($r.ResponseUri) returned content that did not match $pattern"
  } else {
    $true
  }
}