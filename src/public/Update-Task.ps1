function Update-Task {
    <#
        .SYNOPSIS
        Update one or more properties of a specific task.

        .DESCRIPTION
        Adds a new task to a TODO list by Id. It is possible to manage multiple TODO lists in separate databases at once.

        .PARAMETER Id
        Defines the ID of a task that is to be updated.

        .PARAMETER Description
        Sets the description of this task.

        .PARAMETER DueDate
        Sets the due date for this task.

        .PARAMETER Priority
        Sets the perceived priority to this task.

        .PARAMETER Project
        Associates this task with a project (group).

        .PARAMETER Status
        Sets the current status to this task.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        You can pipe Task objects to Update-Task.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Update-Task 1 -Status Done
        Mark the first task as done.

        .EXAMPLE
        PS C:\> Update-Task -Id 42 -Priority High -Status InProgress
        Update the priority of task 42 to high and change its current status to in-progress.

        .EXAMPLE
        PS C:\> Get-TodoList | where { $(Get-Date) -gt $_.DueDate -and $_.Status -ne 'Done' } | Update-Task -Status Discarded
        Search all overdue task records that were never completed and update their status to discarded
    #>
    [Alias("utask")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [int[]] $Id,

        [Parameter()]
        [string] $Project,

        [Parameter()]
        [string] $Description,

        [Parameter()]
        [ValidateSet("High", "Medium", "Low")]
        [string] $Priority,

        [Parameter()]
        [ValidateSet("TODO", "Idea", "Planning", "InProgress", "Testing", "InReview", "Done", "Discarded", "Blocked")]
        [string] $Status,

        [Parameter()]
        [DateTime] $DueDate,

        [Parameter()]
        [string] $User = $env:USERNAME
    )

    begin {
        $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
        $DatabasePath = Join-Path -Path $SavePath -ChildPath "${User}.db"

        if (-not (Test-Path $DatabasePath)) {
            Write-Error -Message "This TODO list does not exist. You can create one with the command 'New-TodoList -User ${User}'" -Category ObjectNotFound -ErrorAction Stop
        }

        $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        foreach ($i in $Id) {
            $Sql = $Connection.CreateCommand()
            $QueryBuilder = New-Object System.Collections.Generic.List[string]
            $QueryBuilder.Add("UPDATE TodoList SET ")

            if ($Project) {
                $QueryBuilder.Add("Project = '${Project}'$(if ($Description -or $Priority -or $Status -or $DueDate) {','} else {''})")
            }
            if ($Description) {
                $QueryBuilder.Add("Description = '${Description}'$(if ($Priority -or $Status -or $DueDate) {','} else {''})")
            }
            if ($Priority) {
                $QueryBuilder.Add("Priority = '${Priority}'$(if ($Status -or $DueDate) {','} else {''})")
            }
            if ($Status) {
                $QueryBuilder.Add("Status = '${Status}'$(if ($DueDate) {','} else {''})")
            }
            if ($DueDate) {
                $QueryBuilder.Add("DueDate = '$($DueDate.ToString("yyyy-MM-dd HH:mm:ss.fffffff"))'")
            }

            $QueryBuilder.Add(" WHERE Id=${i}")
            $Sql.CommandText = $QueryBuilder -Join ''

            if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
                $Sql.ExecuteNonQuery() | Out-Null
            }
        }
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
