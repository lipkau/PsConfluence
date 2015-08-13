#Requires -Version 3.0
<#  Search #>
function Search-ConfluenceSite {
    <#
    .SYNOPSIS
        Search a Confluence Site

    .DESCRIPTION
        Search a Confluence Site

    .NOTES
        AUTHOR : Oliver Lipkau <oliver@lipkau.net>
        VERSION: 0.0.1 - OL - Initial Code
                 1.0.0 - OL - Replaced hashtables with Objects

    .INPUTS
        int
        string
        HashTable

    .OUTPUTS
        Confluence.SearchResult
        Confluence.SearchResult[]

    .EXAMPLE
        Search-ConfluenceSite -apiURi "http://example.com" -token "000000" -query "Lorem" -maxRestuls 10
        -----------
        Description
        Search the Confluence Site for 10 results matching "Lorem"


    .EXAMPLE
        $param = @{apiURi = "http://example.com"; token = "000000"}
        $filter  = @{spaceKey="ABC"}
        Search-ConfluenceSite @param -query "Lorem" -Filter $filter
        -----------
        Description
        Search the Confluence Site for 50 entries matching "Lotem" in Space "ABC"

    .LINK
        Atlassians's Docs:
            Vector<SearchResult> search(String token, String query, int maxResults) - return a list of results which match a given search query (including pages and other content types). This is the same as a performing a parameterised search (see below) with an empty parameter map.
            Vector<SearchResult> search(String token, String query, Map parameters, int maxResults) - (since 1.3) like the previous search, but you can optionally limit your search by adding parameters to the parameter map. If you do not include a parameter, the default is used instead.

    #>
    [CmdletBinding(
        DefaultParameterSetName="search"
    )]
    [OutputType(
        [Confluence.SearchResult],
        [Confluence.SearchResult[]]
    )]
    param(
        # The URi of the API interface.
        [Parameter(
            Position=0,
            Mandatory=$true
        )]
        [string]$apiURi,

        # Confluence's Authentication Token.
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        [string]$Token,

        # String to be seearched for.
        [Parameter(
            Position=2,
            Mandatory=$true
        )]
        [string]$Query,

        # Limit the numer of results. Default is 50.
        [Parameter(
            Position=3,
            ParameterSetName="search"
        )]
        [Parameter(
            Position=4,
            ParameterSetName="searchByParameter"
        )]
        $maxResults = 50,

        # Parameters for Limiting Search Results:
        #        key         |description                           |values                |default
        #        ------------|--------------------------------------|----------------------|--------------------
        #        spaceKey    |search a single space                 |(any valid space key) |Search all spaces
        #        ------------|--------------------------------------|----------------------|--------------------
        #        type        |Limit the content types of the items  |page                  |Search all types
        #                    |to be returned in the search results  |blogpost              |
        #                    |                                      |mail                  |
        #                    |                                      |comment               |
        #                    |                                      |attachment            |
        #                    |                                      |spacedesc             |
        #                    |                                      |userinfo              |
        #                    |                                      |personalspacedesc     |
        #        ------------|--------------------------------------|----------------------|--------------------
        #        modified    |Search recently modified content      |TODAY                 |No limit
        #                    |                                      |YESTERDAY             |
        #                    |                                      |LASTWEEK              |
        #                    |                                      |LASTMONTH             |
        #        ------------|--------------------------------------|----------------------|--------------------
        #        contributor |The original creator or any editor of |Username of a         |Results are not
        #                    |Confluence content. For mail, this is |Confluence user.      |filtered by
        #                    |the person who imported the mail, not |                      |contributor
        #                    |the person who sent the email message.|                      |
        [Parameter(
            Position=3,
            Mandatory=$true,
            ParameterSetName="searchByParameter"
        )]
        [HashTable]$Filter
    )

    Begin
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started" }

    Process {
        switch ($PsCmdlet.ParameterSetName) {
            "search" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Searching without filter for `"$query`""
                $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.search" -Params ($token,$query,($maxResults)))
                if ($response)
                {
                    foreach ($SearchResult in $response)
                    {
                        [Confluence.SearchResult]$SearchResult
                    }
                }
                break
            }
            "searchByParameter" {
                Write-Verbose "$($MyInvocation.MyCommand.Name):: Searching with filters for `"$query`""
                $response = ConvertFrom-Xml (Invoke-ConfluenceCall -Url $apiURi -MethodName "confluence2.search" -Params ($token,$query,$Filter,($maxResults)))
                if ($response)
                {
                    foreach ($SearchResult in $response)
                    {
                        [Confluence.SearchResult]$SearchResult
                    }
                }
                break
            }
        }
    }

    End
        { Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended" }
}
<# /Search #>