#Requires -Version 3.0

<#  Create Confluence Objects #>
Add-Type -TypeDefinition @"
using System;
using System.Collections;
using System.Collections.Generic;

/**
 *
 */
namespace Confluence
{
	/**
 	 * Confluence.ServerInfo
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-serverinfoServerInfo
 	 */
	public class ServerInfo {
		public int majorVersion;
		public int minorVersion;
		public int patchLevel;
		public string buildId;
		public bool developmentBuild;
		public string baseUrl;
	}
	/**
 	 * Confluence.SpaceSummary
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-spacesummarySpaceSummary
 	 */
	public class SpaceSummary {
		public string key;
		public string name;
		public string type;
		public string url;
	}
	/**
 	 * Confluence.Space
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-spaceSpace
 	 */
	public class Space {
		public string key;
		public string name;
		public string url;
		public Int64 homePage;
		public string description;
		public string type;
	}
	/**
 	 * Confluence.PageSummary
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-pagesummaryPageSummary
 	 */
	public class PageSummary {
		public Int64 id;
		public string space;
		public int version;
		public Int64 parentId;
		public string title;
		public string url;
		public int permissions;
	}

 	/**
 	 * Confluence.Page
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-pagePage
 	 */
	public class Page {
		public Int64 id;
		public string space;
		public Int64 parentId;
		public string title;
		public string url;
		public int version;
		public string content;
		public DateTime created;
		public string creator;
		public DateTime modified;
		public string modifier;
		public bool homePage;
		public string contentStatus;
		public bool current;
		public int permissions;
	}

 	/**
 	 * Confluence.PageUpdateOptions
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-pageupdateoptionsPageUpdateOptions
 	 */
	public class PageUpdateOptions {
		public string versionComment;
		public bool minorEdit;
	}

 	/**
 	 * Confluence.PageHistorySummary
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-pagehistorysummaryPageHistorySummary
 	 */
	public class PageHistorySummary {
		public Int64 id;
		public int version;
		public string modifier;
		public DateTime modified;
		public string versionComment;
	}

 	/**
 	 * Confluence.BlogEntrySummary
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-blogentrysummaryBlogEntrySummary
 	 */
	public class BlogEntrySummary {
		public Int64 id;
		public string space;
		public string title;
		public string url;
		public int permissions;
		public DateTime publishDate;
	}

 	/**
 	 * Confluence.BlogEntry
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-blogentryBlogEntry
 	 */
	public class BlogEntry {
		public Int64 id;
		public string space;
		public string title;
		public string url;
		public int version;
		public string content;
		public int permissions;
	}

 	/**
 	 * Confluence.SearchResult
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-searchresultSearchResult
 	 */
	public class SearchResult {
		public string title;
		public string url;
		public string excerpt;
		public string type;
		public Int64 id;
	}

 	/**
 	 * Confluence.Attachment
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-attachmentAttachment
 	 */
	public class Attachment {
		public Int64 id;
		public string pageId;
		public string title;
		public string fileName;
		public string fileSize;
		public string contentType;
		public DateTime created;
		public string creator;
		public string url;
		public string comment;
	}

 	/**
 	 * Confluence.Comment
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-commentComment
 	 */
	public class Comment {
		public Int64 id;
		public string pageId;
		public Int64 parentId;
		public string title;
		public string content;
		public string url;
		public DateTime created;
		public string creator;
		public DateTime modified;
		public string modifier;
	}

 	/**
 	 * Confluence.User
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-userUser
 	 */
	public class User {
		public string name;
		public string fullname;
		public string email;
		public string url;
	}

 	/**
 	 * Confluence.ContentPermission
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-contentpermissionContentPermission
 	 */
	public class ContentPermission {
		public string type;
		public string userName;
		public string groupName;
	}

 	/**
 	 * Confluence.ContentPermissionSet
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-contentpermissionsetContentPermissionSet
 	 */
	public class ContentPermissionSet {
		public string type;
		public List<ContentPermission> contentPermissions;
	}

 	/**
 	 * Confluence.SpacePermissionSet
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-spacepermissionsetSpacePermissionSet
 	 */
	public class SpacePermissionSet {
		public string type;
		public List<ContentPermission> contentPermissions;
	}

 	/**
 	 * Confluence.Label
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-labelLabel
 	 */
	public class Label {
		public string name;
		public string owner;
		public string NameSpace;
		public Int64 id;
	}

 	/**
 	 * Confluence.UserInformation
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-userinformationUserInformation
 	 */
	public class UserInformation {
		public string username;
		public string content;
		public string creatorName;
		public string lastModifierName;
		public int version;
		public Int64 id;
		public DateTime creationDate;
		public DateTime lastModificationDate;
	}

 	/**
 	 * Confluence.ClusterInformation
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-clusterinformationClusterInformation
 	 */
	public class ClusterInformation {
		public bool isRunning;
		public string name;
		public int memberCount;
		public string description;
		public string multicastAddress;
		public string multicastPort;
	}

 	/**
 	 * Confluence.NodeStatus
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-nodestatusNodeStatus
 	 */
	// public class NodeStatus {
	// 	public int nodeId;
	// 	public Map jvmStats;
	// 	public Map props;
	// 	public Map buildStats;
	// }

    /**
 	 * Confluence.ContentSummaries
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-contentsummariesContentSummaries
 	 */
	// public class ContentSummaries {
	// 	public int totalAvailable;
	// 	public int offset;
	// 	public ArrayList<ContentSummary> content;
	// }

 	/**
 	 * Confluence.ContentSummary
 	 *
 	 * https://developer.atlassian.com/confdev/confluence-rest-api/confluence-xml-rpc-and-soap-apis/remote-confluence-dataobjects#RemoteConfluenceDataObjects-contentsummaryContentSummary
 	 */
	public class ContentSummary {
		public Int64 id;
		public string type;
		public string space;
		public string status;
		public string title;
		public DateTime created;
		public string creator;
		public DateTime modified;
		public string modifier;
	}
}
"@
<# /Create Confluence Objects #>