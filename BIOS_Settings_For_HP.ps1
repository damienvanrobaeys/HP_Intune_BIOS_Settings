Param
(
	[string]$MyPassword	
)				

$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\HP_BIOS_Settings.log" 
If(test-path $Log_File)
	{
		remove-item $Log_File -force
	}
new-item $Log_File -type file -force

Function Write_Log
	{
	param(
	$Message_Type, 
	$Message
	)
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)  
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"  
	} 
  
Write_Log -Message_Type "INFO" -Message "Starting the set settings for HP process"  

$Exported_CSV = ".\BIOS_Settings.csv"																																			
$Get_CSV_Content = Import-CSV $Exported_CSV  -Delimiter ";"				
ForEach($Settings in $Get_CSV_Content)
	{
		$MySetting = $Settings.Setting
		$NewValue = $Settings.Value  	
		Write_Log -Message_Type "INFO" -Message "Setting $MySetting and value $NewValue"  
	}

	
$IsPasswordSet = (Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biossetting | Where {$_.Name -eq "Setup Password"}).IsSet							
If (($IsPasswordSet -eq 1))
	{
		Write_Log -Message_Type "INFO" -Message "A password is configured"  
		If($MyPassword -eq "")
			{
				Write_Log -Message_Type "WARNING" -Message "No password has been sent to the script"  	
				Break
			}
	}	
	
		
$bios = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BIOSSettingInterface
ForEach($Settings in $Get_CSV_Content)
	{
		$MySetting = $Settings.Setting
		$NewValue = $Settings.Value		
	
		If (($IsPasswordSet -eq 1))
			{					
				$Password_To_Use = "<utf-16/>"+$MyPassword
				$Execute_Change_Action = $bios.setbiossetting("$MySetting", "$NewValue",$Password_To_Use) 	
				$Change_Return_Code = $Execute_Change_Action.return
				If(($Change_Return_Code) -eq 0)								
					{
						Write_Log -Message_Type "SUCCESS" -Message "New value for $MySetting is $NewValue"  
						
					}
				Else
					{
						Write_Log -Message_Type "ERROR" -Message "Can not change setting $MySetting (Return code $Change_Return_Code)"  						
					}
			}
		Else
			{
				$Execute_Change_Action = $bios.setbiossetting("$MySetting", "$NewValue","")
				$Change_Return_Code = $Execute_Change_Action.return
				If(($Change_Return_Code) -eq 0)								
					{
						Write_Log -Message_Type "SUCCESS" -Message "New value for $MySetting is $NewValue"  						
					}
				Else
					{
						Write_Log -Message_Type "ERROR" -Message "Can not change setting $MySetting (Return code $Change_Return_Code)"  											
					}								
			}
	}	
