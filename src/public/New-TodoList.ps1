function New-TodoList {
    <#
        .SYNOPSIS
        Creates a new database for a TODO list.

        .DESCRIPTION
        Creates a new database for a TODO list. It is possible to manage multiple TODO lists in separate databases at once.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to New-TodoList.

        .OUTPUTS
        None. New-TodoList creates a new system resource, i.e. a database file.

        .EXAMPLE
        PS C:\> New-TodoList
        Create a new TODO list for the active user account.

        .EXAMPLE
        PS C:\> New-TodoList -User "Mazawa Shinonome"
        Create a new TODO list for a specific user.
    #>
    [Alias("ntodo")]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $User = $env:UserName
    )

    begin {
        $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
        $DatabasePath = Join-Path -Path $SavePath -ChildPath "${User}.db"
        $Connection = New-Object -TypeName "System.Data.SQLite.SQLiteConnection"
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        $Sql = $Connection.CreateCommand()
        $Sql.CommandText = Get-Content $(Join-Path -Path $PSScriptRoot -ChildPath "TodoList.sql")
        $Sql.ExecuteNonQuery() | Out-Null
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
