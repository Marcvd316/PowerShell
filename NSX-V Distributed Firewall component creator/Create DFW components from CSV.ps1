############################# INFORMATION #######################################
# Title : NSX-V Distributed Firewall component creator
# Author : Marc Vincent Davoli (Find me on LinkedIn! http://ca.linkedin.com/in/marcvincentdavoli/)
# Description : This script will create and/or import all the necessary Distributed Firewall components including :
#                    Security Groups with a matching Security Tag
#                    Security Groups with a matching IPSet
#                    Security Groups with Dynamic Membership
#                    Services
#                    Service Groups
# PREREQUISITES for this script: Powershell V4+, PowerCLI 6.0R3+, PowerNSX v3+, CSV Files must be in the same folder, see line 30
# INPUT for this script: NSX Manager IP address or hostname, NSX Manager Username, NSX Manager Password
# OUTPUT for this script: List of created Services


############################# CHANGELOG #######################################
# November 2017		First version
# December 2017 	Bugfixes

################################ CONSTANTS ######################################
# Note : See the bundled CSV files for examples of the proper formatting
#

$NSXManagerIP = ""
$NSXManagerUsername = ""
$NSXManagerPassword = ""

$ServicesCSVFile = Import-CSV "Services.csv"
$ServiceGroupsCSVFile = Import-CSV "Service Groups.csv"
$SGST-CSVFile = Import-CSV "Security Groups and Tags.csv"
$SGIPS-CSVFile = Import-CSV "Security Groups and IPSets.csv"
$SGDynamicCSVFile = Import-CSV "Security Groups with Dynamic Membership.csv"

########################################### SERVICES ###################################################
Write-Host "Creating Services" -foregroundcolor "magenta"
foreach ($Line in $ServicesCSVFile) {
    Try {
        Write-Host Creating Service $Line.ServiceName
        New-NsxService $Line.ServiceName -Protocol $Line.ServiceProtocol -Port $Line.ServicePort
    }Catch{
        Write-Host Error with : $Line.ServiceName. Please verify. 
    }
}


Write-Host "Press any key to continue..." -foregroundcolor "blue"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######################################## SERVICE GROUPS ###################################################

Write-Host "Creating Service Groups" -foregroundcolor "magenta"
foreach ($Line in $ServiceGroupsCSVFile) {
    Try {
        Write-Host Creating Service Group $Line.ServiceGroupName
        New-NsxServiceGroup $Line.ServiceGroupName -Description $Line.ServiceGroupDescription
		Get-NsxServiceGroup $Line.ServiceGroupName | Add-NsxServiceGroupMember $Line.ServiceGroupMembers
    }Catch{
        Write-Host Error with : $Line.ServiceGroupName. Please verify. 
    }
}


Write-Host "Press any key to continue..." -foregroundcolor "blue"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######################################## SECURITY GROUPS & TAGS ###################################################

Write-Host "Creating Security Groups that use matching Security Tags" -foregroundcolor "magenta"
foreach ($Line in $SGST-CSVFile) {
    Try {
        Write-Host Creating Security Group $Line.SGName and Security Tag $Line.STName
        New-NsxSecurityGroup $Line.SGName -Description $Line.SGDescription -IncludeMember (New-NsxSecurityTag $Line.STName -Description $Line.Description)
    }Catch{
        Write-Host Error with : $Line.SGName " " $Line.STName. Please verify. 
    }
}


Write-Host "Press any key to continue..." -foregroundcolor "blue"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

######################################## SECURITY GROUPS & IPSETS  ###################################################

Write-Host "Creating Security Groups that use IPSets" -foregroundcolor "magenta"
foreach ($Line in $SGIPS-CSVFile) {
    Try {
        Write-Host Creating Security Group $Line.SGName and IPSet $Line.IPSetName
        New-NsxSecurityGroup $Line.SGName -Description $Line.SGDescription -IncludeMember (New-NsxIPSet -Name $Line.IPSetName -IPAddresses $Line.IPSetAddresses -Description $Line.IPSetDescription)
    }Catch{
        Write-Host Error with : $Line.SGName " " $Line.IPSetName. Please verify. 
    }
}


Write-Host "Press any key to continue..." -foregroundcolor "blue"
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


################################### SECURITY GROUPS WITH DYNAMIC MEMBERSHIP #############################################
# Prepare API request
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($NSXManagerUsername + ":" + $NSXManagerPassword))
    $headers = @{"Authorization"="Basic $auth"}
	$URI = "https://" + $NSXManagerIP +"/api/2.0/services/securitygroup/bulk/globalroot-0"
 
 
Write-Host "Creating Security Groups with Dynamic Membership" -foregroundcolor "magenta"
foreach ($Line in $SGDynamicCSVFile) {
    Try {
        Write-Host Creating Security Group $Line.SGName with Dynamic Membership rules via API
        $r = Invoke-WebRequest -Uri $URI -Method:Post -Headers $headers -ContentType "application/xml" -ErrorAction:Stop -Body $Line.SGXML
	}Catch{
        Write-Host Error with : $Line. Please verify. 
    }
}

Write-Host "Execution complete" -foregroundcolor "blue"
Write-Host "---------------------------------------------------------------" -foregroundcolor "blue"
