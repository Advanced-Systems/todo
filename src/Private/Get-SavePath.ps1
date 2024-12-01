using namespace System
using namespace System.IO

function Get-SavePath {
    [OutputType([Path])]
    param()

    process {
        $ModuleName = "Todo"
        $SavePath = [Path]::Combine([Environment]::GetFolderPath("ApplicationData"), $ModuleName)
        Write-Output $SavePath
    }
}
