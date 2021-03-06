Import-Module $PSScriptRoot\Iwr-tests.psm1 -Force -Prefix Sut- 3>1 | out-null

Describe 'Iwr-tests' {
    function GetOKResponse {
        [PSCustomObject]@{
            StatusCode        = 200
            StatusDescription = 'OK'
        }
    }

    function GetResponseWithHeader {
        [PSCustomObject]@{
            StatusCode        = 200
            StatusDescription = 'OK'
            RawContent = ''
            Headers = @{
                'Content-Type' = 'text/html;'
            }
        }
    }

    function GetResponseWithContent {
        [PSCustomObject]@{
            Content = 'a b c'
        }
    }

    Context 'HaveStatusCode' {
        It 'Should return false when wrong status code is matched' {
            $httpResponse = GetOKResponse
            $isOk, $null = Sut-HaveStatusCode $httpResponse 201
            $isOk | Should Be $false
        }
        It 'Should give an error message when wrong status code is matched' {
            $httpResponse = GetOKResponse
            $null, $message = Sut-HaveStatusCode $httpResponse 201
        }
        It 'Should return true when status code is a match' {
            $httpResponse = GetOKResponse
            $isOk, $null = Sut-HaveStatusCode $httpResponse 200
            $isOk | Should Be $true
        }
    }
    Context 'HaveResponseHeader' {
        It 'Should return false when header not found' {
            $httpResponse = GetResponseWithHeader
            $isOk, $null = Sut-HaveResponseHeader $httpResponse 'Foo' 'Bar'
            $isOk | Should Be $false
        }

        It 'Should return false when header value is not as expected' {
            $httpResponse = GetResponseWithHeader
            $isOk, $null = Sut-HaveResponseHeader $httpResponse 'Content-Type' 'expect-value'
            $isOk | Should Be $false
        }
        
        It 'Should return true when header value is as expected' {
            $httpResponse = GetResponseWithHeader
            $isOk, $null = Sut-HaveResponseHeader $httpResponse 'Content-Type' 'text/html;'
            $isOk | Should Be $true
        }
    }
    Context 'HaveContentThatMatches' {
        It 'Should return false when no match' {
            $httpResponse = GetResponseWithContent
            $isOk, $null = Sut-HaveContentThatMatches $httpResponse 'd'
            $isOk | Should Be $false
        }
        It 'Should return true when match' {
            $httpResponse = GetResponseWithContent
            $isOk, $null = Sut-HaveContentThatMatches $httpResponse 'a\sb'
            $isOk | Should Be $true
        }
    }
}   
