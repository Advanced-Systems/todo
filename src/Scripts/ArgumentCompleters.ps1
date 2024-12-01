using namespace System
using namespace System.IO

$ModuleName = "Todo"

#region User Completer

$UserCompleterCommands = @(
    "Get-Task"
    "Get-TodoList"
    "New-Task"
    "New-TodoList"
    "Remove-Task"
    "Remove-TodoList"
    "Update-Task"
)

$RegisterUserParameter = {
    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParameters)

    $SavePath = [Path]::Combine([Environment]::GetFolderPath("ApplicationData"), $ModuleName)

    Get-ChildItem -Path $SavePath -Filter "*.db" | Where-Object { $_ -like "$WordToComplete*" }
}

$UserCompleterCommands | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_ -ParameterName User -ScriptBlock $RegisterUserParameter
}

#endregion

#region Project Completer

$ProjectCompleterCommands = @(
    "New-Task"
    "Update-Task"
)

$RegisterProjectParameter = {
    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParameters)

    $Projects = Get-TodoList | Select-Object -Property Project -Unique
    $Projects | Where-Object { $_ -like "$WordToComplete*" }
}

$ProjectCompleterCommands | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_ -ParameterName Project -ScriptBlock $RegisterProjectParameter
}

#endregion
