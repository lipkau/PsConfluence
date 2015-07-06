#Requires -Version 3.0
<#  Blog #>
<#function Get-BlogEntry {
    #Vector<BlogEntrySummary> getBlogEntries(String token, String spaceKey) - returns all the summaries in the space.
    #BlogEntry getBlogEntry(String token, String pageId) - returns a single entry.
    #BlogEntry getBlogEntryByDayAndTitle(String token, String spaceKey, int dayOfMonth, String postTitle) - Retrieves a blog post by specifying the day it was published in the current month, its title and its space key.
    #BlogEntry getBlogEntryByDateAndTitle(String token, String spaceKey, int year, int month, int dayOfMonth, String postTitle) - retrieve a blog post by specifying the date it was published, its title and its space key.
}#>
<#function Set-BlogEntry {
    #BlogEntry storeBlogEntry(String token, BlogEntry entry) - add or update a blog entry. For adding, the BlogEntry given as an argument should have space, title and content fields at a minimum. For updating, the entry given should have id, space, title, content and version fields at a minimum. All other fields will be ignored.
}#>
<# /Blog #>