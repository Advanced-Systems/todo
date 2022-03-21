#
# Todo Module Examples
#

# 1) Use the built-in filter parameter to perform simple searches
gtodo -Filter Status -eq 'InProgress'

# 2) Review the description of the last task in list
gtodo | select -Last 1 -Property Description

# 3) Dry-run mass removal of all discarded tasks
gtodo | where Status -eq 'Discarded' | Remove-Task -WhatIf

# 4) Get all high-priority tasks and sort by start date
gtodo | where Priority -eq 'High' | sort StartDate | select Id, Description

# 5) Search all overdue task records that were never completed and update their status to discarded
gtodo | where { $(Get-Date) -gt $_.DueDate -and $_.Status -ne 'Done' } | utask -Status Discarded -WhatIf

# 6) Display the description of task #42
gtask 10 | select Description

# 7) Display the ID and description of all tasks
gtodo -All | select Id, Description
