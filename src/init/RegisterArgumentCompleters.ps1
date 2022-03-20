using namespace System.Management.Automation

$CommandNames = @(
    "Get-TodoList"
    "New-Task"
    "New-TodoList"
    "Remove-Task"
    "Remove-TodoList"
    "Update-Task"
)

$RegisterUserParameter = {
    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
    $Users = Get-ChildItem -Path $SavePath -Filter "*.db" | ForEach-Object { Write-Output $_.BaseName }
    $Users | ForEach-Object { [CompletionResult]::new($_) }
}

$CommandNames | ForEach-Object { Register-ArgumentCompleter -CommandName $_ -ParameterName User -ScriptBlock $RegisterUserParameter }

$RegisterProjectParameter = {
    param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $Projects = Get-TodoList | Select-Object -Property Project -Unique
    $Projects | ForEach-Object { [CompletionResult]::new($_.Project) }
}

@("New-Task", "Update-Task") | ForEach-Object { Register-ArgumentCompleter -CommandName $_ -ParameterName Project -ScriptBlock $RegisterProjectParameter }

