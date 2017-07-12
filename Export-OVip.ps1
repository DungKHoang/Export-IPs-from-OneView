## -------------------------------------------------------------------------------------------------------------
##
##
##      Description: Export IP addresses
##
## DISCLAIMER
## The sample scripts are not supported under any HPE standard support program or service.
## The sample scripts are provided AS IS without warranty of any kind. 
## HP further disclaims all implied warranties including, without limitation, any implied 
## warranties of merchantability or of fitness for a particular purpose. 
##
##    
## Scenario
##     	Export OneView resources
##	
## Description
##      The script exports all IPs used in Synergy frames   
##
## History: 
##
##         July 2017         -First release
##                         
##   Version : 3.1
##
##   Version : 3.1 July 2017
##
## Contact : Dung.HoangKhac@hpe.com
##
##
## -------------------------------------------------------------------------------------------------------------
<#
  .SYNOPSIS
     Export resources to OneView appliance.
  
  .DESCRIPTION
	 Export resources to OneView appliance.
        
  .EXAMPLE

    .\ Export-OVip.ps1  -OVApplianceIP 10.254.1.66 -OVAdminName Administrator -password P@ssword1 -OVipCSV .\ip.csv 
        The script connects to the OneView appliance and exports IP addresses to the ip.csv file


  .PARAMETER OVApplianceIP                   
    IP address of the OV appliance

  .PARAMETER OVAdminName                     
    Administrator name of the appliance

  .PARAMETER OVAdminPassword                 
    Administrator s password


  .PARAMETER OVipCSV
    Path to the CSV file containing IP addresses

  .PARAMETER OneViewModule
    Module name for POSH OneView library.
	
  .PARAMETER OVAuthDomain
    Authentication Domain to login in OneView.

  .Notes
    NAME:  Export-OVResources
    LASTEDIT: 07/14/2017
    KEYWORDS: OV  Export
   
  .Link
     Http://www.hpe.com
 
 #Requires PS -Version 3.0
 #>
  
## -------------------------------------------------------------------------------------------------------------

Param ( [string]$OVApplianceIP="", 
        [string]$OVAdminName="", 
        [string]$OVAdminPassword="",

        [string]$OVipAddressCSV        = "ip.csv",  
        [string]$OVAuthDomain          = "local",
        [string]$OneViewModule         = "HPOneView.310"
)  



$Delimiter = "\"   # Delimiter for CSV profile file
$Sep       = ";"   # USe for multiple values fields
$SepChar   = '|'
$CRLF      = "`r`n"
$OpenDelim = "={"
$CloseDelim = "}" 
$CR         = "`n"
$Comma      = ','

$IPHeader   = "Location,Type,BayNumber,ipAddress"




## -------------------------------------------------------------------------------------------------------------
##
##                     Function Export-OVipAddress
##
## -------------------------------------------------------------------------------------------------------------

Function Export-OVipAddress ([string]$OutFile)
{    
    $ValuesArray = @()
    
    $AppNetwork  = (Get-HPOVApplianceNetworkConfig).ApplianceNetworks

    $Type        = "Appliance"
    $appName     = $appNetwork.hostname
    $appIP       = $appNetwork.virtIPv4addr
    $app1IP      = $appNetwork.app1Ipv4Addr  
    $app2IP      = $appNetwork.app2Ipv4Addr  

    $ValuesArray      += "$appName,$Type,,$appIP"
    $ValuesArray      += "$appName,$Type,Maintenance IP address 1,$app1IP"
    $ValuesArray      += "$appName,$Type,Maintenance IP address 2,$app2IP"
    $ValuesArray      += ",,,"

    ## ------------
    ##  Enclosures : IP from Device Bays and InterConnect Bays
    ## -------------
    $ListofEnclosures = Get-HPOVEnclosure
    foreach ($Encl in $ListofEnclosures)
    {
        $enclName         = $Encl.Name

        ## Device Bay IP
        $Type             = "Device Bay"
        $ListofDeviceBays = $Encl.DeviceBays
        foreach ($Bay in $ListofDeviceBays)
        {
            $BayNo        = $Bay.bayNumber
            $ipv4Setting  = $Bay.ipv4Setting
            if ($ipv4Setting)
            {  
                $BayIP     = $Bay.ipv4Setting.ipAddress
                $ValuesArray  += "$enclName,$type,$BayNo,$BayIP"
            }
            
        }

        ## InterConnect Bay IP
        $Type                   = "InterConnect Bay"
        $ListofInterconnectBays = $Encl.InterconnectBays
        foreach ($IC in $ListofInterConnectBays)
        {
            
            $ICBayNo     =  $IC.bayNumber 
            $ipv4Setting =  $IC.ipv4Setting
            if ($ipv4Setting)
            {   
                $ICIP          =  $IC.ipv4Setting.ipAddress 
                $ValuesArray  += "$enclName,$type,$ICBayNo,$ICIP"
            }
        }

        ## Next enclosure - Adding a blank line to the output file
        $ValuesArray += ",,,"
    }
    if ($ValuesArray -ne $NULL)
    {
        $a= New-Item $OutFile  -type file -force
        Set-content -Path $OutFile -Value $IPHeader
        Add-content -path $OutFile -Value $ValuesArray

    }

}

## -------------------------------------------------------------------------------------------------------------
##
##                     Main Entry
##
## -------------------------------------------------------------------------------------------------------------

       # -----------------------------------
       #    Always reload module
   
       #$OneViewModule = $OneViewModule.Split('\')[-1]   # In case we specify a full path to PSM1 file

       $LoadedModule = get-module -listavailable $OneviewModule


       if ($LoadedModule -ne $NULL)
       {
            $LoadedModule = $LoadedModule.Name.Split('.')[0] + "*"
            remove-module $LoadedModule
       }

       import-module $OneViewModule



        # ---------------- Connect to OneView appliance
        #
        write-host -foreground Cyan "$CR Connect to the OneView appliance..."
         Connect-HPOVMgmt -appliance $OVApplianceIP -user $OVAdminName -password $OVAdminPassword -AuthLoginDomain $OVAuthDomain

        if ($OVipAddressCSV)
        { 
            write-host -ForegroundColor Cyan "Exporting IP addresses to CSV file --> $OVipAddressCSV"
           
            Export-OVipAddress     -Outfile $OVipAddressCSV            
        }
        
        write-host -foreground Cyan "$CR Disconnect from the OneView appliance..."
        Disconnect-HPOVMgmt
