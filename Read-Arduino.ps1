$COM = [System.IO.Ports.SerialPort]::GetPortNames()

function read-com () {
    $port = New-Object System.IO.Ports.SerialPort COM3,9600,None,8,one
    $port.open()
    do {
        $line = $port.Readline()
        write-host $line
    }
    while ($port.IsOpen)
}

read-com