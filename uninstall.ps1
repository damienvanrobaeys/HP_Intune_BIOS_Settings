$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\HP_BIOS_Settings.log" 
If(test-path $Log_File){Remove-item $Log_File -force}