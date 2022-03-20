# Changelog

## Version 1.2.0 (2022-03-20)

Implement `Register-ArgumentCompleter` for all functions that offer a `User` or `Project` parameter.
Set `ConfirmImpact` to `High` in `Remove-TodoList` to prevent the user from accidentally removing
their TODO list.

## Version 1.1.1 (2022-02-23)

Deprecate the `-Query` parameter everywhere which was previously used for directly making SQL queries
from the terminal. The `Get-TodoList` Cmdlet now provides a `-Filter` parameter which is much more
user-friendly:

```powershell
# get all active tasks
Get-TodoList -Filter Status -eq 'InProgress'
```

Additionally, both `Remove-Task` and `Update-Task` now implement `ValueFromPipelineByPropertyName`:

```powershell
# remove all tasks from the current user's TODO list that were marked as done
Get-TodoList -All | where Status -eq 'Done' | Remove-Task -WhatIf
```

```powershell
# search all overdue task records that were never completed and update their status to discarded
Get-TodoList | where { $(Get-Date) -gt $_.DueDate -and $_.Status -ne 'Done' } | Update-Task -Status Discarded
```

## Version 1.0.1 (2022-02-21)

Fix an error in which `New-TodoList` expected a `Todo` directory to already exist in `%AppData%`, and
improve the error message in `Get-TodoList` in case the user attempts to open a TODO list that does not
exist yet.

## Version 1.0.0 (2022-02-20)

Initial release of the `Todo` module. Implements the following Cmdlets:

-   `New-TodoList`
-   `Get-TodoList`
-   `Remove-TodoList`
-   `New-Task`
-   `Update-Task`
-   `Remove-Task`
