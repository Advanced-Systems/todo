function New-Task {
    <#
        .SYNOPSIS
        Adds a new task to a TODO list.

        .DESCRIPTION
        Adds a new task to a TODO list. It is possible to manage multiple TODO lists in separate databases at once.

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
        None. You cannot pipe objects to New-Task.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> New-Task "Update VM"
        Add a new item to the current user's TODO list. Description is the only required parameter in this Cmdlet, all other properties will be automatically populated with their respective default values.

        .EXAMPLE
        PS C:\> New-Task -Description "Review PR #186" -Project "Backend" -Priority Medium
        NOTE: You can always update specific Properties later with the Update-Task Cmdlet.
    #>
    [Alias("ntask")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Description,

        [Parameter()]
        [string] $Project = "Default",

        [Parameter()]
        [ValidateSet("High", "Medium", "Low")]
        [string] $Priority = "Low",

        [Parameter()]
        [ValidateSet("TODO", "Idea", "Planning", "InProgress", "Testing", "InReview", "Done", "Discarded", "Blocked")]
        [string] $Status = "TODO",

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
        $Today = Get-Date
    }
    process {
        $Sql = $Connection.CreateCommand()
        $Param1 = $Sql.Parameters.AddWithValue("@Id", $null)
        $Param2 = $Sql.Parameters.AddWithValue("@Project", $Project)
        $Param3 = $Sql.Parameters.AddWithValue("@Description", $Description)
        $Param4 = $Sql.Parameters.AddWithValue("@Priority", $Priority)
        $Param5 = $Sql.Parameters.AddWithValue("@Status", $Status)
        $Param6 = $Sql.Parameters.AddWithValue("@StartDate", $Today)
        $Param7 = $Sql.Parameters.AddWithValue("@DueDate", $(if ($DueDate) { $DueDate } else { [DateTime]::new($Today.Year, 12, 31) }))
        $Sql.CommandText = "INSERT INTO TodoList (Id,Project,Description,Priority,Status,StartDate,DueDate) VALUES (@Id,@Project,@Description,@Priority,@Status,@StartDate,@DueDate)"

        if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
            $Sql.ExecuteNonQuery() | Out-Null
        }
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
