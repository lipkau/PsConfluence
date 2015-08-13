#Requires -Version 3.0
<#  Attachement #>
#Gets are in <Pages/>
<#function Add-Confluencettachment {
    #Attachment addAttachment(String token, long contentId, Attachment attachment, byte[] attachmentData) - add a new attachment to a content entity object. Note that this uses a lot of memory - about 4 times the size of the attachment. The 'long contentId' is actually a String pageId for XML-RPC. Be aware of  CONF-31169 and CONF-30024.
}#>
<#function Remove-ConfluenceAttachment {
    #boolean removeAttachment(String token, String contentId, String fileName) - remove an attachment from a content entity object.
}#>
<#function Move-ConfluenceAttachment {
    #boolean moveAttachment(String token, String originalContentId, String originalName, String newContentEntityId, String newName) - move an attachment to a different content entity object and/or give it a new name.
}#>
<# /Attachement #>