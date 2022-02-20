# Todo

## Description

`Todo` is an open-source PowerShell module to manage your TODO list from the terminal. All tasks are locally stored
in a SQLite database located in a app data sub-directory.

## Required Modules

- [`SQListe`](https://www.nuget.org/packages/System.Data.SQLite/)

Review the module manifest:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Advanced-Systems/todo/master/src/Todo.psd1 -OutFile Todo.psd1
Import-PowerShellDataFile Todo.psd1 | Write-Output
```

## Basic Usage

```powershell
New-TodoListh
New-Task "Update VM"
New-Task -Description "Schedule meeting with PO" -Priority High
Get-TodoList
New-Task -Description "Review PR #186" -Project "Backend"
Get-TodoList | where Priority -eq 'High' | fl
Update-Task -Id 2 -Status Done
Remove-Task -Id 2
```

## Remarks

The default view is formatted by `TaskTable.ps1xml` which only displays `Id`, `Project`, `Status`, `Priority` and `Description`.
Pipe the output from `Get-TodoList` to `Formaat-List` (alias: `fl`) to print all other properties as well.

## Command Reference

Use the comment-based help (`Get-Help <cmd> -Examples`) to review more examples.

```powershell
# list all available commands
Get-Command -Module Todo
# list all exported aliases
Get-Alias | where Source -eq Todo
```
