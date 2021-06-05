<# para inputbox #>
Add-Type -AssemblyName Microsoft.VisualBasic;

$i = 0;
$desred = @();
$namred = @();
$red = Get-NetAdapter -Name * -IncludeHidden;
foreach ($mired in $red)
{
	if ($mired.status -eq "up")
	{
		$desred = $desred + $mired.InterfaceDescription;
		$namred = $namred + $mired.name; 
		$i++;
		Write-Host "($i). "$mired.name; 
	}
}

$ingrese = $i + 1;
while ($ingrese -gt $i -or $ingrese -lt 1)
{
	$ingrese = [Microsoft.VisualBasic.Interaction]::InputBox('Ingrese numero de interface', '_');
	$ingrese = $ingrese.Trim(); 
}

"`n"
try
{
	$valor = (Get-WmiObject Win32_NetworkAdapterConfiguration | where-object { $_.description -eq $desred[$ingrese - 1] } | select *);
	Write-Host "      ipv6: " $valor.ipaddress[1]; 
	Write-Host "      ipv4: " $valor.ipaddress[0]; 
	Write-Host "      mask: " $valor.ipsubnet[0]; 
	Write-Host "pta.enlace: " $valor.DefaultIPGateway[0]; 
	
	#poniendo ip 
	$er = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
	
	While (1)
	{
		$nueip = [Microsoft.VisualBasic.Interaction]::InputBox('Ingrese nueva ip', '_'); 
		$nueip = $nueip.Trim();
		if ($nueip -match $er)
		{
			break;
		}
	}
	$r = 1;
	try
	{
		#remover ip 
		Get-NetIPAddress -InterfaceAlias $namred[$ingrese-1] | Remove-NetIPAddress;
		#poniendo nueva ip 
		$nuevaip = [IpAddress]$nueip; 
		New-NetIPAddress -InterfaceAlias $namred[$ingrese-1] -IPAddress $nuevaip; 
	}
	catch [System.Exception]
	{
		[System.Windows.Forms.Messagebox]::Show("No se pudo hacer el cambio");
		$r = 0;
		exit; 
	}
	if ($r -eq 1)
	{
		[System.Windows.Forms.Messagebox]::Show("La IP ha cambiado");
	}
}
catch [System.Exception]
{
	Write-Host "el valor es nulo"; 
	exit; 
}
