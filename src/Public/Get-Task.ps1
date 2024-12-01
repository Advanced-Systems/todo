using namespace System
using namespace System.Data
using namespace System.Data.SQLite
using namespace System.IO

function Get-Task {
    <#
        .SYNOPSIS
        Get a task by ID.

        .DESCRIPTION
        Get a task by ID. See also Get-TodoList.

        .PARAMETER Id
        Defines the ID of a task that is to be searched.

        .PARAMETER User
        Each TODO list is associated to a user account. The default user account
        is read from the username environment variable. Specify a value for this
        parameter to access an another TODO list from a different user.

        .INPUTS
        You can pipe IDs as integers to Get-Task.

        .OUTPUTS
        A Task object.

        .EXAMPLE
        PS C:\> Get-Task 42 | select Description
        Get the description of task #42.

        .EXAMPLE
        PS C:\> 1..10 | Get-Task
        Get the first ten tasks in your TODO list. If there are currently less
        than ten tasks in your TODO list, return the entire TODO list instead.
    #>
    [Alias("gtask")]
    [OutputType("Task")]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [int[]] $Id,

        [Parameter()]
        [string] $User = [Environment]::UserName
    )

    begin {
        $SavePath = Get-SavePath
        $DatabasePath = [Path]::Combine($SavePath, "${User}.db")

        if (!(Test-Path $DatabasePath)) {
            Write-Error $DatabaseDoesNotExistErrorMessage -Category ObjectNotFound -ErrorAction Stop
        }

        $Connection = [SQLiteConnection]::new()
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        foreach ($i in $Id) {
            $Sql = $Connection.CreateCommand()
            $Sql.CommandText = "SELECT * FROM TodoList WHERE Id = $i"

            try {
                $Adapter = [SQLiteDataAdapter]::new($Sql)
                $Data = [DataSet]::new()
                [void] $Adapter.Fill($Data)

                $Task = $Data.Tables[0] | ForEach-Object {
                    [Task]::new(
                        $_.Id,
                        $_.Project,
                        $_.Description,
                        $_.Priority,
                        $_.Status,
                        $_.StartDate,
                        $_.DueDate
                    )
                }

                Write-Output $Task
            } catch {
                Write-Error $DatabaseConnectionErrorMessage -Category ConnectionError -ErrorAction Stop
            } finally {
                $Sql.Dispose()
            }
        }
    }
    clean {
        $Connection.Close()
    }
}
