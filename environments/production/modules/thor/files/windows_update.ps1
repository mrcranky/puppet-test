#Download and install software updates from WU that are selected by default

param (
    [Parameter(Mandatory=$true)][Datetime]$threshold
)
 
function WriteEvent ($eventMessage,$eventType,$eventID)
{
    Write-Host $eventMessage
}

WriteEvent "Checking for updates after date: $threshold"
 
#Software updates only, selected by default, not already installed
$criteria="IsInstalled=0 and Type='Software' and AutoSelectOnWebSites=1"
$resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" }
$updateSession = New-Object -ComObject 'Microsoft.Update.Session'
WriteEvent 'Windows Update process is starting.' 'Information' '1000'
WriteEvent "Beginning check for available updates based on the following criteria: $criteria." 'Information' '1001'
$updates = $updateSession.CreateupdateSearcher().Search($criteria).Updates
if ($updates.Count -eq 0)
{
    WriteEvent 'Check for available updates is complete.  There are no updates to apply.' 'Information' '1001'
}   
else
{
    WriteEvent "Check for available updates is complete.  There are $($updates.Count) updates to apply." 'Information' '1001'
    foreach ($update in $updates)
    {
        if ($update.LastDeploymentChangeTime -lt $threshold)
        {
            WriteEvent "Old enough: $($update.Title) => $($update.LastDeploymentChangeTime)"
        }
        else
        {
            WriteEvent "Too New: $($update.Title) => $($update.LastDeploymentChangeTime)"
        }
    }
	
    #Create download object
    $downloader = $updateSession.CreateUpdateDownloader()
    $downloader.Updates = $Updates 
    WriteEvent 'Beginning download of available updates.' 'Information' '1002'
    $result= $downloader.Download()  
    if (($result.Hresult -eq 0) -and (($result.resultCode -eq 2) -or ($result.resultCode -eq 3)))
        {
        WriteEvent 'Download of available updates has completed.' 'Information' '1002'
        $updatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
        $updates | Where-Object {$_.isdownloaded} | Foreach-Object {$updatesToInstall.Add($_) | Out-Null}
        #Create installer object
        $installer = $updateSession.CreateUpdateInstaller()
        $installer.Updates = $updatesToInstall
        WriteEvent "Beginning installation of downloaded updates `($($installer.Updates.count)`)." 'Information' '1003'
        #Run installation of downloaded files
        $installationResult = $installer.Install()
        $global:counter=-1
        $installResults = $installer.updates | Select-Object -property Title,EulaAccepted,@{label='Result'; `
            expression={$resultCode[$installationResult.GetUpdateResult($($global:counter++)).resultCode]}}
        WriteEvent ($installResults | Format-Table -Wrap | Out-String) 'Information' '1002'
        }
    else
        {
        WriteEvent 'Error downloading updates.' 'Warning' '1001'
        }
    }
WriteEvent 'Windows Update process is complete.' 'Information' '1010'
 
#Reboot
#Restart-Computer -Force -Confirm:$false
