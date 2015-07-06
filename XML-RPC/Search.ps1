#Requires -Version 3.0
<#  Search #>
<#function Search-Site {
    #Vector<SearchResult> search(String token, String query, int maxResults) - return a list of results which match a given search query (including pages and other content types). This is the same as a performing a parameterised search (see below) with an empty parameter map.
    #Vector<SearchResult> search(String token, String query, Map parameters, int maxResults) - (since 1.3) like the previous search, but you can optionally limit your search by adding parameters to the parameter map. If you do not include a parameter, the default is used instead.
        #Parameters for Limiting Search Results:
        #key         |description                           |values                |default
        #------------|--------------------------------------|----------------------|--------------------
        #spaceKey    |search a single space                 |(any valid space key) |Search all spaces
        #------------|--------------------------------------|----------------------|--------------------
        #type        |Limit the content types of the items  |page                  |Search all types
        #            |to be returned in the search results  |blogpost              |
        #            |                                      |mail                  |
        #            |                                      |comment               |
        #            |                                      |attachment            |
        #            |                                      |spacedesc             |
        #            |                                      |userinfo              |
        #            |                                      |personalspacedesc     |
        #------------|--------------------------------------|----------------------|--------------------
        #modified    |Search recently modified content      |TODAY                 |No limit
        #            |                                      |YESTERDAY             |
        #            |                                      |LASTWEEK              |
        #            |                                      |LASTMONTH             |
        #------------|--------------------------------------|----------------------|--------------------
        #contributor |The original creator or any editor of |Username of a         |Results are not
        #            |Confluence content. For mail, this is |Confluence user.      |filtered by 
        #            |the person who imported the mail, not |                      |contributor
        #            |the person who sent the email message.|                      |
}#>
<# /Search #>