Add-Type -assembly System.Windows.Forms

# ----- FORM DEFINITION ----- #
$Form = New-Object System.Windows.Forms.Form
$Form.Text = 'Lab setup'
$Form.Size = New-Object System.Drawing.Size(610,360)
$Form.StartPosition = 'CenterScreen'
$Form.AutoScroll = $true
$Form.FormBorderStyle = 'FixedSingle'

 

$CountLabel = New-Object System.Windows.Forms.Label
$CountLabel.Location = New-Object System.Drawing.Size(100,100)
$CountLabel.Autosize = $true
$CountLabel.Font = New-Object System.Drawing.Font('Arial Narrow', 12, [System.Drawing.FontStyle]::Bold)
$CountLabel.ForeColor = 'Red'
$Form.Show()

# ----- SCript----- #
# ********************************** #
Start-Job -name messagetrace -FilePath "C:\Users\Administrator.ADATUM\Documents\Lab Setup\LabSetupScript.ps1"


# ----- COUNT ----- #
$waittime = 300



# ----- VMOVER JOB STATUS CHECK ----- #
# *********************************** #   
$startTime = get-date
$testflag = 0
$endTime   = $startTime.addSeconds($waittime)
while ((get-date) -lt $endTime) 
    {
        if(($waittime % 10) -eq 0)
        {
            $jobstate = (Get-Job -Name messagetrace).State
            if($jobstate -match "completed")
            {
                $CountLabel.Text = ('Finished')
                $CountLabel.ForeColor = 'green'
                $Form.Controls.Add($CountLabel)
                $Form.Refresh()
                $testflag = 1
                Break
                
            }
            elseif($jobstate -match 'failed')
            {
                Remove-Job -Name messagetrace
                $errorVmover = new-object -comobject wscript.shell
                $responseErrorVmover = $errorVmover.popup("Lab Setup failed. EXITING...”,0,“Failed”,0+4096)
                $Form.Close()
                Return
            }
        }
                $CountLabel.Text = ('Setting up lab' + (". "*(5-($waittime%5))))
                $Form.Controls.Add($CountLabel)
                $Form.Refresh()
                write-host $waittime
                $waittime -=1  
                sleep 1
     }
    if($testflag -eq 0)
    {
        $errorVmover = new-object -comobject wscript.shell
        $responseErrorVmover = $errorVmover.popup('Lab Setup failed. EXITING...',0,'Failed',0+4096)
        $Form.Close()
        Return
    }
     if($testflag -eq 1)
    {
        $errorVmover = new-object -comobject wscript.shell
        $responseErrorVmover = $errorVmover.popup('Lab Setup Completed. EXITING...',0,'COMPLETED',0+4096)
        $Form.Close()
        Return
    }
