using namespace System.Net
param($Request, $TriggerMetadata)  # Input bindings are passed in via param block.

#Get-Module -ListAvailable
Write-Host "PowerShell HTTP trigger function processed a request." # Write to the Azure Functions log stream.
$responsePayload = @{ message = "Hello $($request.Query.Name)" } | ConvertTo-Json -Depth 2
Push-OutputBinding -Name Response -Value (
	[HttpResponseContext]@{
		StatusCode = [HttpStatusCode]::OK
		Body       = $responsePayload
		Headers    = @{ "Content-Type" = "application/json" }
	}
) # Associate values to output bindings by calling 'Push-OutputBinding'.

#URL: https://ayanM.azurewebsites.net/api/One?name=Ayan