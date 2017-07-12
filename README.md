# Collect IP addresses of all components in OneView

Export-OVIP.ps1 is a PowerShell script that collects IP address of all components (iLO, Interconnect Bay) managed by OneView.
The script queries servers in enclosures only ( C7000 / Synergy)

## Prerequisites
The script leverages the follwoing PowerShell libraries:
* OneView PowerShell library : https://github.com/HewlettPackard/POSH-HPOneView/releases




## Syntax


```
    .\Export-OVIP.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -OVipCSV c:\ip.csv -OneViewModule HPOneView.310

```

## Output

    Check the samples.zip for output of the script.
