#region Install autorest and generate module from existing OpenAPI definition file
npm install -g autorest -verbose

<#older attempt
autorest --powershell --input-file=.Myfolder\generated\openapi.yaml --output-folder=.Myfolder\generated\OneFunction `
	--namespace=OneFunction --clear-output-folder=true `
	--module-version=1.0.0 --use=@autorest/powershell@latest --verbose
#>

cd .AutorestPS
$verbosePreference = "Continue"

#One can test the raw definition file on https://petstore.swagger.io/ once it's added to the Function's CORS

autorest --powershell --input-file=openapi.yaml --output-folder=.\One --namespace=OneFunction `
         --clear-output-folder=true --module-version=1.0.0 --use=@autorest/powershell@latest --verbose

# The '.AutorestPS\One' folder is added in the .funcignore file so it isn't pushed into the function

cd One
.\build-module.ps1
#endregion

#region test the module
Import-Module .\OneFunctionApi.psd1
<#VERBOSE: Loading module from path '<>\AzFuncFlex\.AutorestPS\One\OneFunctionApi.psd1'.
VERBOSE: Loading 'Assembly' from path '<>\AzFuncFlex\.AutorestPS\One\bin\OneFunctionApi.private.dll'.
VERBOSE: Loading 'FormatsToProcess' from path '<>\AzFuncFlex\.AutorestPS\One\OneFunctionApi.format.ps1xml'.
VERBOSE: Loading module from path '<>\AzFuncFlex\.AutorestPS\One\OneFunctionApi.psm1'.
VERBOSE: Loading module from path '<>\AzFuncFlex\.AutorestPS\One\bin\OneFunctionApi.private.dll'.
VERBOSE: Importing cmdlet 'Export-CmdletSurface'.
VERBOSE: Importing cmdlet 'Export-ExampleStub'.
VERBOSE: Importing cmdlet 'Export-FormatPs1xml'.
VERBOSE: Importing cmdlet 'Export-HelpMarkdown'.
VERBOSE: Importing cmdlet 'Export-ModelSurface'.
VERBOSE: Importing cmdlet 'Export-ProxyCmdlet'.
VERBOSE: Importing cmdlet 'Export-Psd1'.
VERBOSE: Importing cmdlet 'Export-TestStub'.
VERBOSE: Importing cmdlet 'Get-CommonParameter'.
VERBOSE: Importing cmdlet 'Get-ModuleGuid'.
VERBOSE: Importing cmdlet 'Get-ScriptCmdlet'.
VERBOSE: Importing cmdlet 'Get-OneGreeting_Get'.
VERBOSE: Loading module from path '<>\AzFuncFlex\.AutorestPS\One\custom\OneFunctionApi.custom.psm1'.
VERBOSE: Importing cmdlet 'Export-CmdletSurface'.
VERBOSE: Importing cmdlet 'Export-ExampleStub'.
VERBOSE: Importing cmdlet 'Export-FormatPs1xml'.
VERBOSE: Importing cmdlet 'Export-HelpMarkdown'.
VERBOSE: Importing cmdlet 'Export-ModelSurface'.
VERBOSE: Importing cmdlet 'Export-ProxyCmdlet'.
VERBOSE: Importing cmdlet 'Export-Psd1'.
VERBOSE: Importing cmdlet 'Export-TestStub'.
VERBOSE: Importing cmdlet 'Get-CommonParameter'.
VERBOSE: Importing cmdlet 'Get-ModuleGuid'.
VERBOSE: Importing cmdlet 'Get-ScriptCmdlet'.
VERBOSE: Importing cmdlet 'Get-OneGreeting_Get'.
VERBOSE: Loading module from path '<>\AzFuncFlex\.AutorestPS\One\internal\OneFunctionApi.internal.psm1'.
VERBOSE: Importing cmdlet 'Export-CmdletSurface'.
VERBOSE: Importing cmdlet 'Export-ExampleStub'.
VERBOSE: Importing cmdlet 'Export-FormatPs1xml'.
VERBOSE: Importing cmdlet 'Export-HelpMarkdown'.
VERBOSE: Importing cmdlet 'Export-ModelSurface'.
VERBOSE: Importing cmdlet 'Export-ProxyCmdlet'.
VERBOSE: Importing cmdlet 'Export-Psd1'.
VERBOSE: Importing cmdlet 'Export-TestStub'.
VERBOSE: Importing cmdlet 'Get-CommonParameter'.
VERBOSE: Importing cmdlet 'Get-ModuleGuid'.
VERBOSE: Importing cmdlet 'Get-ScriptCmdlet'.
VERBOSE: Importing cmdlet 'Get-OneGreeting_Get'.
VERBOSE: Exporting function 'Get-OneGreeting'.
VERBOSE: Importing function 'Get-OneGreeting'.
#>

Get-OneGreeting -Name Ayan -Debug
<#DEBUG: CmdletBeginProcessing:
DEBUG: CmdletProcessRecordStart:
DEBUG: CmdletProcessRecordAsyncStart:
DEBUG: CmdletGetPipeline:
DEBUG: CmdletBeforeAPICall:
DEBUG: URLCreated: /api/One?name=Ayan
DEBUG: RequestCreated: /api/One?name=Ayan
DEBUG: HeaderParametersAdded:
DEBUG: BeforeCall:
DEBUG: ResponseCreated:
DEBUG: BeforeResponseDispatch:
DEBUG: Finally:
DEBUG: CmdletAfterAPICall:
DEBUG: CmdletProcessRecordAsyncEnd:
DEBUG: CmdletProcessRecordEnd:

DEBUG: CmdletEndProcessing:
Message
-------
Hello Ayan
#>


cd ..
dotnet new sln -n OneFunctionApi
dotnet sln OneFunctionApi.sln add .\One\OneFunctionApi.csproj

#endregion


#region command to generate the OpenAPI document in a C# function
#From the root of the C# Azure Functions project (where host.json lives), run:

func openapi export --format yaml --output ./openapi.yaml
#(or use --format json if you prefer JSON). This command is available once the project references Microsoft.Azure.WebJobs.Extensions.OpenApi.
#endregion