#
# Module manifest for module "Todo"
#
# Generated by: Stefan Greve
#
# Generated on: 2/19/2022
#

@{
    RootModule = "Todo.psm1"
    ModuleVersion = "1.3.0"
    CompatiblePSEditions = @("Desktop")
    GUID = "1005fb56-c909-4fd8-87db-0d6d57de726c"
    Author = "Stefan Greve"
    CompanyName = "Advanced Systems"
    Copyright = "(c) 2022 Advanced Systems. All rights reserved."
    Description = "PowerShell Module to manage your TODO list from the terminal."
    PowerShellVersion = "5.1"
    RequiredModules = @("SQLite")
    FormatsToProcess = @("TodoTable.Format.ps1xml")

    FunctionsToExport = @(
        "Get-Task",
        "Get-TodoList",
        "New-Task",
        "New-TodoList",
        "Remove-Task"
        "Remove-TodoList",
        "Update-Task"
    )

    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @(
        "gtask", # Get-Task
        "gtodo", # Get-TodoList
        "ntask", # New-Task
        "ntodo", # New-TodoList
        "rtask", # Remove-Task
        "rtodo", # Remove-TodoList
        "utask"  # Update-Task
    )

    FileList = @(
        "Todo.psd1",
        "Todo.psm1",
        "TodoTable.Format.ps1xml",
        "classes\Task.ps1",
        "init\RegisterArgumentCompleters.ps1",
        "public\Get-Task.ps1",
        "public\Get-TodoList.ps1",
        "public\New-Task.ps1",
        "public\New-TodoList.ps1",
        "public\Remove-Task.ps1",
        "public\Remove-TodoList.ps1",
        "public\TodoList.sql",
        "public\Update-Task.ps1"
    )

    PrivateData = @{
        PSData = @{
            Tags = @("PSEdition_Desktop", "Windows", "Todo", "Productivity")
            LicenseUri = "https://www.gnu.org/licenses/gpl-3.0.en.html"
            ProjectUri = "https://github.com/Advanced-Systems/todo"
            ReleaseNotes = "https://github.com/Advanced-Systems/todo/blob/master/CHANGELOG.md"
        }
    }
}
