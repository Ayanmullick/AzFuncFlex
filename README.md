# AzFuncFlex

This repository shows a small PowerShell Azure Functions API and the local scaffolding used to generate a PowerShell
module for that API.

At the moment the API is intentionally simple: the `One` function accepts an HTTP GET request with a `name` query
parameter and returns a JSON greeting:

```http
GET https://ayanm.azurewebsites.net/api/One?name=Ayan
```

```json
{
  "message": "Hello Ayan"
}
```

The interesting part of the repo is that the function can also be consumed through a generated PowerShell cmdlet:

```powershell
Get-OneGreeting -Name Ayan
```

## How The Pieces Fit Together

There are two related but separate things in this repo:

| Path | Purpose |
| --- | --- |
| `One/` | The actual Azure Functions PowerShell HTTP trigger. This is the API implementation. |
| `.AutorestPS/openapi.yaml` | The OpenAPI description of the HTTP API. This is the contract AutoRest reads. |
| `.AutorestPS/Generate.ps1` | Notes and commands for generating, building, and testing the PowerShell module. |
| `.AutorestPS/One/` | The generated PowerShell module output. This folder is regenerated from the OpenAPI file. |
| `.funcignore` | Excludes `.AutorestPS/` so the generated client module is not deployed as part of the function app. |

In plain terms:

1. The Azure Function exposes an HTTP endpoint.
2. The OpenAPI file describes that endpoint in a machine-readable way.
3. AutoRest reads the OpenAPI file and generates a PowerShell module.
4. The generated module gives users a normal PowerShell command instead of making them hand-write HTTP calls.

## Prerequisites

To regenerate the module locally, install:

- PowerShell
- Node.js and npm
- .NET SDK
- AutoRest, installed by the generation command below

The generated module calls the URL listed in `.AutorestPS/openapi.yaml` under `servers`. If the Azure Function host name
changes, update that URL before regenerating the module.

## Generate The PowerShell Module

Most of this flow is captured in `.AutorestPS/Generate.ps1`. From the repository root, the core steps are:

```powershell
npm install -g autorest -verbose

Set-Location .AutorestPS
$VerbosePreference = 'Continue'

autorest --powershell --input-file=openapi.yaml --output-folder=.\One --namespace=OneFunction `
  --clear-output-folder=true --module-version=1.0.0 --use=@autorest/powershell@latest --verbose

Set-Location .\One
.\build-module.ps1
```

What those commands do:

- `npm install -g autorest -verbose` installs the AutoRest command-line tool.
- `autorest --powershell ...` reads `.AutorestPS/openapi.yaml` and generates a PowerShell module into `.AutorestPS/One`.
- `--clear-output-folder=true` deletes and recreates the generated module output so stale generated files are removed.
- `--use=@autorest/powershell@latest` tells AutoRest to use the PowerShell generator.
- `.\build-module.ps1` compiles and prepares the generated module.

## Test The Generated Module

After building the module:

```powershell
Import-Module .\OneFunctionApi.psd1 -Force
Get-OneGreeting -Name Ayan -Debug
```

The expected result is a response object with a greeting message:

```text
Message
-------
Hello Ayan
```

The `-Debug` output is useful when learning how the generated cmdlet maps back to the HTTP API. For this API, it should
show a request being created for:

```text
/api/One?name=Ayan
```

## Updating The API Contract

If the Azure Function shape changes, update `.AutorestPS/openapi.yaml` before regenerating the module. The generated
cmdlet names, parameters, and response models come from this OpenAPI file.

For example, the current operation uses:

- Path: `/api/One`
- Method: `GET`
- Query parameter: `name`
- Operation ID: `One_GetGreeting`

AutoRest uses that information to create the exported `Get-OneGreeting` PowerShell function.

## API Language Does Not Matter

The PowerShell module generation does not depend on the language used to build the API. AutoRest only needs the OpenAPI
definition file.

In this repo the API implementation is a PowerShell Azure Function, but the same generation steps would work for a C#
Azure Function, a Node.js API, a Python API, or any other service as long as it has an accurate OpenAPI file. For this
repo, that file is `.AutorestPS/openapi.yaml`.

From the root of a C# Azure Functions project (where host.json lives), one can run:
`func openapi export --format yaml --output ./openapi.yaml`
(or use --format json if you prefer JSON). This command is available once the project references Microsoft.Azure.WebJobs.Extensions.OpenApi.