+++
title = "API for the Azure DevOps Team Calendar"
slug = "ado-team-calendar"
date = "2024-05-18T16:15:00+01:00"
description = "API for the Azure DevOps Team Calendar"
categories = ["automation", "devops"]
tags = ["azure devops", "automation", "devops"]

+++

Azure DevOps has an extension that provides [a calendar for each Team](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.team-calendar&targetId=b2bf9ecf-25cc-486f-82cb-6111d79e2adc&utm_source=vstsproduct&utm_medium=ExtHubManageList), but the API is not documented. These notes cover API methods for the Team calendar, to enable automation.

## Installing The Team Calendar

Add the [Azure DevOps Team Calendar](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.team-calendar&targetId=b2bf9ecf-25cc-486f-82cb-6111d79e2adc&utm_source=vstsproduct&utm_medium=ExtHubManageList) from the Marketplace to your organization in Azure DevOps.

## URL Format

To access a calendar, you must build a URL that specifies your Azure DevOps _organization_, the _teamId_ of the Team, and the _month_ and _year_ that are relevant for the operation:

```text
https://extmgmt.dev.azure.com/{organisation}/_apis/ExtensionManagement/InstalledExtensions/ms-devlabs/team-calendar/Data/Scopes/Default/Current/Collections/{teamId}.{monthNumber}.{year}/Documents
```

You must include an API version with calls that create, update or delete a calendar event:

```text
https://extmgmt.dev.azure.com/{organisation}/_apis/ExtensionManagement/InstalledExtensions/ms-devlabs/team-calendar/Data/Scopes/Default/Current/Collections/{teamId}.{monthNumber}.{year}/Documents?api-version=6.1-preview.1
```

{{< alert >}}
It seems that the API will accept any version, but the query string for _api-version_ must include the string _-preview_.
{{< /alert >}}

## API Calls

You access the calendar resources through the [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops).

### GET Calendar Events

Issue a GET request on the main URL:

```text
https://extmgmt.dev.azure.com/{organisation}/_apis/ExtensionManagement/InstalledExtensions/ms-devlabs/team-calendar/Data/Scopes/Default/Current/Collections/{teamId}.{monthNumber}.{year}/Documents
```

This returns a document with this structure:

```json
{
  "count": 1,
  "value": [
    {
      "category": "Uncategorized",
      "description": "",
      "endDate": "2021-02-03T00:00:00Z",
      "startDate": "2021-02-03T00:00:00Z",
      "title": "Example event 1",
      "__etag": 1,
      "id": "f14fd3ff-f39b-4d23-a353-6e3dfbf3af4a"
    }
  ]
}
```

A month with no events will return a document with this structure:

```json
{
  "count": 0,
  "value": []
}
```

### PUT New Calendar Event

Send a JSON document with this structure:

```json
{
  "category": "Uncategorized",
  "description": "",
  "endDate": "2021-03-01T00:00:00Z",
  "startDate": "2021-03-01T00:00:00Z",
  "title": "Example event 21"
}
```

### PUT Update Calendar Event

To delete a calendar event, send a HTTP PUT request. This is the format of the JSON document:

```json
{
  "__etag": 3,
  "id": "290d0223-0256-432d-9c18-a6fed6e8b5e3",
  "category": "Uncategorized",
  "description": "",
  "endDate": "2021-02-01T00:00:00Z",
  "startDate": "2021-02-01T00:00:00Z",
  "title": "Example event 1"
}
```

Note that this includes the _id_ of the calendar, and an _\_\_etag_ value. Always set the _\_\_etag_ value as the current _\_\_etag_ value of the event, plus one. The [Data Storage](https://docs.microsoft.com/en-us/azure/devops/extend/develop/data-storage?view=azure-devops) that Team Calendar uses relies on the etag value for locking.

### DELETE Calendar Event

To delete a calendar event, send a HTTP DELETE request to a URL that includes the ID for the event:

```text
https://extmgmt.dev.azure.com/{organisation}/_apis/ExtensionManagement/InstalledExtensions/ms-devlabs/team-calendar/Data/Scopes/Default/Current/Collections/{teamId}.{monthId}.{year}/Documents/{eventId}?api-version=6.1-preview.1
```

This returns a HTTP 204 response, with an empty body.

## Error Structure

Errors return a JSON document with this structure:

```json
{
  "$id": "1",
  "innerException": null,
  "message": "%error=\"1660000\";%:The document already exists",
  "typeName": "Microsoft.VisualStudio.Services.ExtensionManagement.WebApi.DocumentExistsException, Microsoft.VisualStudio.Services.ExtensionManagement.WebApi",
  "typeKey": "DocumentExistsException",
  "errorCode": 0,
  "eventId": 3000
}
```

## Resources

- [Azure DevOps Team Calendar](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.team-calendar&targetId=b2bf9ecf-25cc-486f-82cb-6111d79e2adc&utm_source=vstsproduct&utm_medium=ExtHubManageList)
- [Team Calendar GitHub project](https://github.com/microsoft/vsts-team-calendar)
- [Team Calendar uses Data Storage](https://docs.microsoft.com/en-us/azure/devops/extend/develop/data-storage?view=azure-devops)
- [How to integrate an Azure Devops Calendar into Outlook](https://stackoverflow.com/questions/60988989/how-to-integrate-an-azure-devops-calendar-into-outlook/61222307) - The answer here from Starian Chen was the start of this work
