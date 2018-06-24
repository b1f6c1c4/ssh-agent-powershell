function Start-SshAgent
{
	$running = Get-SshAgent
	if ($running -ne $null) {
		write-warning "ssh-agent is running at pid = $($running.id)"
		return
	}

	$shout = & "C:\Program Files\git\usr\bin\ssh-agent.exe" -c
	$shout | foreach-object {
		$parts = $_ -split " "
		if ($parts[0] -ieq "setenv") {
			$val = $parts[2] -replace ";$",""
			[Environment]::SetEnvironmentVariable($parts[1], $val, "User")
			[Environment]::SetEnvironmentVariable($parts[1], $val, "Process")
		} elseif ($parts[0] -ieq "echo") {
			$val = $parts[1..$($parts.count)] -join " "
			write-host $val
		} else {
			write-warning "Unknown command: $_"
		}
	}
}

function Get-SshAgent
{
	if ($env:SSH_AGENT_PID -ne $null) {
		$proc = Get-Process -pid $env:SSH_AGENT_PID -ea SilentlyContinue
		if ($proc -ne $null) {
			if ($proc.ProcessName -eq "ssh-agent") {
				$proc
				return
			}
		}
	}

	[Environment]::SetEnvironmentVariable("SSH_AGENT_PID", $null, "User")
	[Environment]::SetEnvironmentVariable("SSH_AGENT_PID", $null, "Process")
	[Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", $null, "User")
	[Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", $null, "Process")
	$null
}

function Stop-SshAgent
{
	$agent = Get-SshAgent
	if ($agent -ne $null) {
		stop-process $agent
		[Environment]::SetEnvironmentVariable("SSH_AGENT_PID", $null, "User")
		[Environment]::SetEnvironmentVariable("SSH_AGENT_PID", $null, "Process")
		[Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", $null, "User")
		[Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", $null, "Process")
	}
}
