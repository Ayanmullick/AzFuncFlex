using namespace System.Net
param($Request, $TriggerMetadata)  # Input bindings are passed in via param block.

Write-Host "PowerShell HTTP trigger function processed a request." # Write to the Azure Functions log stream.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{StatusCode = [HttpStatusCode]::OK  ; Body = "Hello $($request.Query.Name)"}) # Associate values to output bindings by calling 'Push-OutputBinding'.

#URL: https://ayanM.azurewebsites.net/api/One?name=Ayan