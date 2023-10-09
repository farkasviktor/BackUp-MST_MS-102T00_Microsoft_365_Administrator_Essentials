install-packageprovider NuGet -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name ExchangeOnlineManagement -Force
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force
Import-Module ExchangeOnlineManagement -Force
Connect-ExchangeOnline
Connect-IPPSSession

Start-Sleep -Seconds 5
$labelname = "PII - V1"
$labeldescription = "Documents, files, and emails with PII"
$tooltip = "Documents, files, and emails with PII"

$conditions = '{
        "And": [
            {
                "And": [
                    {
                        "Key": "CCSI",
                        "Value": "cb353f78-2b72-4c3c-8827-92ebe4f69fdf",
                        "Properties": null,
                        "Settings": [
                            {
                                "Key": "name",
                                "Value": "ABA Routing Number"
                            },
                            {
                                "Key": "groupname",
                                "Value": "Default"
                            },
                            {
                                "Key": "mincount",
                                "Value": "1"
                            },
                            {
                                "Key": "maxcount",
                                "Value": "499"
                            },
                            {
                                "Key": "confidencelevel",
                                "Value": "Medium"
                            },
                            {
                                "Key": "policytip",
                                "Value": "Sensitive content has been detected and will be encrypted"
                            }
                        ]
                    },
                    {
                        "Key": "CCSI",
                        "Value": "a44669fe-0d48-453d-a9b1-2cc83f2cba77",
                        "Properties": null,
                        "Settings": [
                            {
                                "Key": "name",
                                "Value": "U.S. Social Security Number (SSN)"
                            },
                            {
                                "Key": "groupname",
                                "Value": "Default"
                            },
                            {
                                "Key": "mincount",
                                "Value": "1"
                            },
                            {
                                "Key": "maxcount",
                                "Value": "499"
                            },
                            {
                                "Key": "confidencelevel",
                                "Value": "Medium"
                            },
                            {
                                "Key": "policytip",
                                "Value": "Sensitive content has been detected and will be encrypted"

                            }
                        ]
                    }
                ]
            }
        ]
    }'
 
$label = New-Label `
            -DisplayName $labelname `
            -Name $labelname `
            -Comment $labeldescription `
            -Tooltip $tooltip `
            -Conditions $conditions

 
Set-Label `
    -Identity $label.Id `
    -LabelActions '{
    "Type":"encrypt",
    "SubType":null,
    "Settings":[{"Key":"protectiontype","Value":"removeprotection"},
                {"Key":"disabled","Value":"false"}
                ]
    }'
 
Set-Label `
    -Identity $label.Id `
    -LabelActions '{
    "Type":"applycontentmarking",
    "SubType":"header",
    "Settings":[{"Key":"text","Value":"Sensitive - Do Not Share"},
                {"Key":"fontsize","Value":"25"},
                {"Key":"fontcolor","Value":"#FF0000"},
                {"Key":"alignment","Value":"Center"},
                {"Key":"margin","Value":"5"},
                {"Key":"placement","Value":"Header"}
                ]
    }'
 
Set-Label `
    -Identity $label.Id `
    -LabelActions '{
    "Type":"applycontentmarking",
    "SubType":"footer",
    "Settings":[{"Key":"text","Value":"Sensitive - Do Not Share"},
                {"Key":"fontsize","Value":"25"},
                {"Key":"fontcolor","Value":"#FF0000"},
                {"Key":"alignment","Value":"Center"},
                {"Key":"margin","Value":"5"},
                {"Key":"placement","Value":"Footer"}
                ]
    }'
 
Set-Label `
    -Identity $label.Id `
    -LabelActions '{
    "Type":"applywatermarking",
    "SubType":null,
    "Settings":[{"Key":"text","Value":"Sensitive - Do Not Share"},
                {"Key":"fontsize","Value":"25"},
                {"Key":"fontcolor","Value":"#0000FF"},
                {"Key":"layout","Value":"Diagonal"}
                ]
    }'

Start-Sleep -Seconds 10

Set-Label -Identity "PII - V1" -ContentType "File, Email, Teamwork"

Start-Sleep -Seconds 10

# PowerShell script to create a new-labelpolicy
$users = Get-ExoMailbox | Where-Object { $_.PrimarySmtpAddress -notlike 'DiscoverySearchMailbox*' }
$Name = "PII Policy - V1"
$ID = Get-Label -Identity "PII - V1" 
$Settings = @{
    "mandatory"                    = $false;
    "powerbimandatory"             = $false;
    "outlookdefaultlabel"          = $ID.ImmutableId;
    "requiredowngradejustification"= $true;
    "defaultlabelid"               = $ID.ImmutableId;
    "powerbidefaultlabelid"        = $ID.ImmutableId;
    "teamworkmandatory"            = $false;
    "disablemandatoryinoutlook"    = $true;
    "teamworkdefaultlabelid"       = $ID.ImmutableId;
}
$Labels = "PII - V1"
$Comment = @"
The purpose of this policy is to detect sensitive information such as ABA bank routing numbers and US social security numbers in emails and documents, and to encrypt this information when it's discovered. The user must provide an explanation for removing the classification label
"@

# Create the label policy
New-LabelPolicy -Name $Name -Settings $Settings -Labels $Labels -Comment $Comment -ExchangeLocation $users.PrimarySmtpAddress

