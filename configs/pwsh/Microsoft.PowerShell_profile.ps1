Write-Output "gm/ga/ge/gn hmuy"
oh-my-posh init pwsh --config $env:USERPROFILE\candy_custom.omp.json | Invoke-Expression
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
function reboot {
	Restart-Computer
}
Set-Alias -name reboot -v reboot
function gh {
	Set-Location $env:USERPROFILE\Documents\gh
}
Set-Alias -name ghub -value gh
function btop{
	btop4win
}
Set-Alias -name btop -value btop