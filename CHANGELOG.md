# Changelog

## Version 1.0.1 (2022-02-21)

Fix an error in `New-TodoList` expected a `Todo` directory to already exist in `%AppData%`, and
improve the error message in `Get-TodoList` in case the user attempts to open a TODO list which
does not exist yet.

## Version 1.0.0 (2022-02-20)

Initial release of the `Todo` module. Implements the following Cmdlets:

- `New-TodoList`
- `Get-TodoList`
- `Remove-TodoList`
- `New-Task`
- `Update-Task`
- `Remove-Task`
