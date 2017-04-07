## Move all pictures from SourceFolders to RootFolder, and rearrange into YearMonth of PhotoCreatedDate
## ------

$SourceFolders = @('D:\iPhonePix\Pix_all\')
$RootFolder    = 'D:\iPhonePix\Pix_out'

function Get-Images {
    [CmdletBinding()] 
    Param(
    [Parameter(Mandatory=$true,  Position=0)]
        [ValidateScript({ (Test-Path -Path $_) })]
        [String[]]$Source, 
    [Parameter(Mandatory=$false, Position=1)]
        [String[]]$Extension = @('.JPG','.PNG')
    )

    # Get folder list
    $Folders = @()
    $Duration = Measure-Command { 
        $Source | % { 
            $Subfolders = (Get-ChildItem -Path $Source -Recurse -Directory -Force).FullName 
            if ($Subfolders -ne $null)
            {
                $Folders += (Get-ChildItem -Path $Source -Recurse -Directory -Force).FullName 
            }
        }
    }
    Write-Verbose "Got '$($Folders.Count)' folder(s) in $($Duration.Minutes):$($Duration.Seconds) mm:ss"
    $Folders += $Source
 
    $Images = @()
    $objShell  = New-Object -ComObject Shell.Application
    $Folders | % {
    
        $objFolder = $objShell.namespace($_)
        foreach ($File in $objFolder.items()) { 
        
            if ($objFolder.getDetailsOf($File, 157) -in $Extension) {

                Write-Verbose "Processing file '$($File.Path)'"
                $Props = [ordered]@{
                    Name          = $File.Name
                    FullName      = $File.Path
                    Size          = $File.Size
                    Type          = $File.Type
                    Extension     = $objFolder.getDetailsOf($File,156)
                    DateCreated   = $objFolder.getDetailsOf($File,3)
                    DateModified  = $objFolder.getDetailsOf($File,4)
                    DateAccessed  = $objFolder.getDetailsOf($File,5)
                    DateTaken     = $objFolder.getDetailsOf($File,12)
                    CameraModel   = $objFolder.getDetailsOf($File,30)
                    CameraMaker   = $objFolder.getDetailsOf($File,32)
                    BitDepth      = [int]$objFolder.getDetailsOf($File,165)
                    HorizontalRes = $objFolder.getDetailsOf($File,166)
                    VerticalRes   = $objFolder.getDetailsOf($File,168)
                    Width         = $objFolder.getDetailsOf($File,167)
                    Height        = $objFolder.getDetailsOf($File,169)
                }
                $Images += New-Object -TypeName psobject -Property $Props

            } # if $Extension

        } # foreach $File

    } # foreach $Folder
    $Images

} # function

Get-Images $SourceFolders | % {
    $tmp = $_.DateCreated.Split('/')
    $YearTaken = $tmp[2].Split(' ')[0]
    if ($tmp[0].length -lt 2) {
        $MonthTaken = "0" + $tmp[0]
    } else {
        $MonthTaken = $tmp[0]
    }

    if (-not (Test-Path -Path "$RootFolder\$YearTaken$MonthTaken")) { 
        "Creating folder '$RootFolder\$YearTaken$MonthTaken'"
        New-Item -Path "$RootFolder\$YearTaken$MonthTaken" -ItemType Directory -Force -Confirm:$false
    }
    "Moving image '$($_.Name)' from '$(Split-Path -Path $_.FullName )' to '$RootFolder\$YearTaken$MonthTaken'"
    Move-Item -Path $_.FullName -Destination "$RootFolder\$YearTaken$MonthTaken" -Force -Confirm:$false
}
