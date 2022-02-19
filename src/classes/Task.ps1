class Task {
    [ValidateNotNullOrEmpty()][int] $Id
    [ValidateNotNullOrEmpty()][string] $Project
    [ValidateNotNullOrEmpty()][string] $Description
    [ValidateSet("High", "Medium", "Low")][string] $Priority
    [ValidateSet("TODO", "Idea", "Planning", "InProgress", "Testing", "InReview", "Done", "Discarded", "Blocked")][string] $Status
    [ValidateNotNullOrEmpty()][DateTime] $StartDate
    [ValidateNotNullOrEmpty()][DateTime] $DueDate
    [TimeSpan] $Age

    Task([string]$Id, [string]$Project, [string]$Description, [string]$Priority, [string]$Status, [DateTime]$StartDate, [DateTime]$DueDate) {
        $this.Id = $Id
        $this.Project = $Project
        $this.Description = $Description
        $this.Priority = $Priority
        $this.Status = $Status
        $this.StartDate = $StartDate
        $this.DueDate = $DueDate
        $this.Age = $(Get-Date) - $StartDate
    }
}
