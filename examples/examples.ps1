#
# TodoList Recipes
#

# 1 use the built-in filter parameter to perform simple searches
gtodo -Filter Status -eq 'InProgress'

# 2. review the description of the last task in list
gtodo | select -Last 1 -Property Description

# 3. dry-run mass removal of all discarded tasks
gtodo | where Status -eq 'Discarded' | Remove-Task -WhatIf

# 4. get all high-priority tasks and sort by start date
gtodo | where Priority -eq 'High' | sort StartDate | select Id, Description

# 5. search all overdue task records that were never completed and update their status to discarded
gtodo | where { $(Get-Date) -gt $_.DueDate -and $_.Status -ne 'Done' } | utask -Status Discarded -WhatIf
