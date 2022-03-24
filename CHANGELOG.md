# Changelog

## Version 1.3.1 (2022-03-24)

Small bug fixes for the custom formatting rules and type output declarations.

## Version 1.3.0 (2022-03-21)

Implement a new Cmdlet to inspect single tasks more conveniently:

```powershell
# get the description of task #42
Get-Task 42 | select Description

# get the first ten tasks in your TODO list
1..10 | Get-Task
```

Additionally, `Get-TodoList` no longer returns tasks where the status is set to `Discarded` unless
you add the `-All` switch to the command invocation. Moreover, this function now explicitly states
its return type which further improves the auto-completion feature in the terminal.

Last but not least, the error handling has been improved in the following functions:

-   `New-Task`
-   `Remove-Task`
-   `Update-Task`

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
