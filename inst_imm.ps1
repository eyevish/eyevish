#===============================IMM Installer====================================
#  Script will create a Virtual swtich for networking 
#  and create a Hyper-V machine that connects via switch
#  it will have access to the host and the internet 
#  but not to other hosts in the network.
#================================================================================
#statics
$VMName="IMM_XPI"
$MEMSize=4294967296       #to get the value of n GB - this is n * (1024^3)
$DynamicMem=$false
$InstPath="${env:APPDATA}\MSE\"
$cpuCount= (Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors/2

$vhdx_Arc="imm_xpi.zip"
$vhdx="imm_xpi.vhdx"



#script internal constants ------
$ethName="xpi-Internal"
$natName="xpi-nat"
#script internal global variables
$currMemSize=0
$currCPUSize=0
# -------------------------------

function fnLog {
  param (
    $message
  )
  Write-Host $(Get-Date): $message
}

function fnGetInput {
  param ($message, $regex ,$errStr )
    do {
    if ($confirmation -ne $null) {Write-Host $errStr}
    $confirmation = Read-Host $message
    } until ($confirmation -match $regex)
    return $confirmation
  }

function Cleanup {  
    Remove-VM $VMName -Force
    Remove-VMSwitch -Name $ethName -Force
    Remove-NetIPAddress -IPAddress "192.17.0.1" -confirm:$false
    Remove-NetNat $natName -confirm:$false
    exit
}

function Extract-Zip ($ZipFilePath, $Destination){
	$ZipFile = "$(Get-Item $ZipFilePath)"				#Tostring of path of filesname sent
	#TODO Need to check for Null and $Destination exists to return error where necessary
    $Shell = New-Object -Comobject "Shell.Application"
    $SourceZip = $Shell.Namespace($ZipFile).items()
    $DestinationFolder = $Shell.Namespace($Destination)
    $DestinationFolder.CopyHere($SourceZip)
}

function CreateVM {
#CREATE NEW-VM
# Make/extract a copy of the image to the InstPath and create VM there. Assign the switch
# the memory and pocessor

  fnLog "Begin image extraction."
  Extract-Zip $vhdx_Arc $InstPath
  fnLog "Image extraction complete."
  fnLog "Configuring VM begin."
	New-VM -VHDPath $InstPath$vhdx -Generation 2 -MemoryStartupBytes $MEMSize -Name $VMName -Path $InstPath -SwitchName $ethName
  Set-VMFirmware -VMName  $VMName -EnableSecureBoot Off
  if (!$DynamicMem) {Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false}
  Set-VMProcessor -VMName $VMName -Count $cpuCount
  fnLog "VM creation complete."
}


function SetupNet {
# CREATE INTERNAL NETWORK
If (Get-VMSwitch -Name $ethName -SwitchType Internal  -ErrorAction Ignore) {
        fnLog "A Virtual Swtich with a similar name already exists  `n->>> `t`tif this was not expected - run the command again with '-C' as argument to clean up."
    } else {
        fnLog "Creating VM switch."
        New-VMSwitch -SwitchName $ethName -SwitchType Internal 
        #New-NetIPAddress -IPAddress 172.172.0.1 -PrefixLength 24 -InterfaceIndex $(Get-NetAdapter -Name "vEthernet (${ethName})" | Select-Object -Exp ifIndex)
        New-NetIPAddress -IPAddress 192.17.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (${ethName})"
        New-NetNat -Name $natName -InternalIPInterfaceAddressPrefix 192.17.0.0/24
        fnLog "Adding IP to host"
        Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n192.17.0.11   imm.xpi.net"
        fnLog "Network configuration complete"
    }
  }


function fnSetMemSize{
# Get Memory Size
  $currMemSize = (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / $([Math]::pow(1024,3))
  Write-Host "`nAvailable memory in System: $currMemSize GB"
  $MEMSize=[int]$(fnGetInput "Please assign the Mem size in GB " "[4-9]|[1-9][0-9]" "Invalid input - minimum 4 GB required.")
  Write-Host "Memory assigned will be : " -NoNewLine; Write-Host "$MEMSize GB" -ForegroundColor Magenta
  $MEMSize = $($MEMSize * [Math]::pow(1024,3))
}

function fnSetCPUSize{
# Get CPU Size
  $currCPUSize = (Get-WmiObject Win32_Processor | Select-Object -Property NumberOfLogicalProcessors).NumberOfLogicalProcessors
  Write-Host "`nAvailable LogicalProcessors: $currCPUSize"
  $cpuCount =[int]$(fnGetInput "Please assign the # of processors for the VM" "[1-9]|[1-9][0-9]" "Invalid input - minimum 1 Processor required.")
  Write-Host "CPU capacity assigned will be : " -NoNewLine; Write-Host "$cpuCount Processor" -ForegroundColor Magenta
}

function StartVM {
#  StartVM
#  Prompt user to start VM 
  $yn= $(fnGetInput "`nWould you like to start the VM now (Y/N)?" "[YyNn]" "Please enter Y or N...").ToUpper()
  if ($yn -ne 'N') {
    Start-VM -Name $VMName

    fnLog "VM started !! Magic xpi monitor should be available @ http://imm.xpi.net/magicmonitor , monitor startup may take a couple of minutes"
  } else {
    Write-Host "IMM Server was not started. You can open the 'Hyper-V Manager' to start the VM or `nrun the command 'Start-VM -Name $VMName' in a powershell window."
  }
}

function custommization {
Write-Host "`nThe default Memory allocation to the VM is set to: $($MEMSize / [Math]::pow(1024,3)) GB"
Write-Host "The default CPU resource allocation is: $cpuCount Logical Processors"

$yn= $(fnGetInput "`nWould you like to customise these parameters now (Y/N)?" "[YyNn]" "Please enter Y or N...").ToUpper()
  if ($yn -ne 'N') {
      fnSetMemSize
      fnSetCPUSize
  }
}

#================================================================================
#------Main section for all action/sequence -----------------------------------
#================================================================================
if ($args[0] -eq '-C') { Cleanup }
custommization
SetupNet      # CREATE INTERNAL NETwORK
CreateVM      #CREATE NEW-VM
fnLog "Done :image deploy complete.`n`n"
StartVM

Write-Host "`t`t============================================================"
Write-Host '`t`t` Hint: Run "inst_imm.bat -C" to clean up the installation'
Write-Host "`t`t============================================================"
