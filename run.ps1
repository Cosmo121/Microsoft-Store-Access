<# 
Enable Microsoft Store Access
For corporate devices that have access restricted
#>


#$winStoreKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore\RemoveWindowsStore'
$ServiceName = 'wuauserv'
$arrService = Get-Service -Name $ServiceName
$storeProcess = Get-Process WinStore.app -ErrorAction SilentlyContinue

$storeProcess | Stop-Process -Force -ErrorAction SilentlyContinue
    

If ((test-path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore") -eq $False) {
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    New-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -name RemoveWindowsStore -value 0
    Write-Host "Creating key, and setting key value to 0"
} ElseIf (((Get-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -name RemoveWindowsStore).RemoveWindowsStore) -eq 1) {
    Set-ItemProperty -path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -name RemoveWindowsStore -value 0
    Write-Host "Updating key value to 0"
    } Else {
    "It's already set! (apparently)"
} #endif/else


if ($arrService.Status -eq "Running") {
    Restart-Service -Force -Name wuauserv -ErrorAction SilentlyContinue
    Write-Host "Restarting Windows Update Service"
    Start-Sleep -seconds 10
}
else {
    while ($arrService.Status -eq "Stopped") {
        Start-Service $ServiceName
        Write-Host "Starting Windows Update Service"
        Start-Sleep -seconds 10
        $arrService.Refresh()
        if ($arrService.Status -eq "Running") {
            Write-Host "Service started successfully"
        }
    }
}

#TODO Start Microsoft Store app automatically at end
