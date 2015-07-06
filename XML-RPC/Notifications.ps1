#Requires -Version 3.0
<#  Notifications #>
<#function Set-Watch {
    #boolean watchPage(String token, long pageId) - watch a page or blog post as the current user, returns false if a space, page or blog is already being watched
    #boolean watchSpace(String token, String spaceKey) - watch a space as the current user, returns false if the space is already watched
    #boolean watchPageForUser(String token, long pageId, String username) - add a watch on behalf of another user (space administrators only)
}#>
<#function Remove-Watch {
    #boolean removePageWatch(String token, long pageId) - remove a page or blog post watch as the current user, returns false if the space, page or blog isn't being watched
    #boolean removeSpacewatch(String token, String spaceKey) - remove a space watch as the current user, returns false if the space isn't being watched
    #boolean removePageWatchForUser(String token, long pageId, String username) - remove a watch on behalf of another user (space administrators only)
}#>
<#function Test-Watch {
    #boolean isWatchingPage(String token, long pageId, String username) - check whether a user is watching a page (space administrators only, if the username isn't the current user)
    #boolean isWatchingSpace(String token, String spaceKey, String username) - check whether a user is watching a space (space administrators only, if the username isn't the current user)
}
<#function Get-Watch {
    #Vector<User> getWatchersForPage(String token, long pageId) - return the watchers for the page (space administrators only)
    #Vector<User> getWatchersForSpace(String token, String spaceKey) - return the watchers for the space (space administrators only).
}#>
<# /Notifications #>