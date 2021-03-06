<p align="center">
  <a title="Project Logo">
    <img height="150" style="margin-top:15px" src="https://raw.githubusercontent.com/Advanced-Systems/vector-assets/master/advanced-systems-logo-annotated.svg">
  </a>
</p>

<h1 align="center">Advanced Systems Todo List</h1>

`Todo` is an open-source PowerShell module to manage your TODO list from the terminal. All tasks are locally stored
in a SQLite database located in a app data sub-directory. This module can be installed from [PowerShell Gallery](https://www.powershellgallery.com/)
with

```powershell
Install-Module -Name Todo
```

## Required Modules

- [`SQList`](https://www.powershellgallery.com/packages/SQLite/2.0)

Review the module manifest:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Advanced-Systems/todo/master/src/Todo.psd1 -OutFile Todo.psd1
Import-PowerShellDataFile Todo.psd1 | Write-Output
```

## Basic Usage

```powershell
New-TodoList
New-Task "Update VM"
New-Task -Description "Schedule meeting with PO" -Priority High
Get-TodoList
New-Task -Description "Review PR #186" -Project "Backend"
Get-TodoList | where Priority -eq 'High' | fl
Update-Task -Id 2 -Status Done
Remove-Task 2
```

For more examples, have a look at `.\examples\examples.ps1`.

## Remarks

The default view is formatted by `TaskTable.ps1xml` which only displays `Id`, `Project`, `Status`, `Priority` and `Description`.
Pipe the output from `Get-TodoList` to `Format-List` (alias: `fl`) to see all other properties as well.

## Command Reference

Use the comment-based help (`Get-Help <cmd> -Examples`) to see more examples.

```powershell
# list all available commands
Get-Command -Module Todo
# list all exported module aliases
Get-Alias | where Source -eq Todo
```
