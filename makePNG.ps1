# PS script makePNG.ps1
#
# assumes the parameter(s) are .txt files which contain valid Plant UML markup
# produces a png using the plantuml.jar, which should be located in JAVA_HOME\..\ext
#
# Declare input parameters
param(
    [string] $file="",
    [string] $format="png",
    [string] $type ="uml"
)

#
# setup some needed things
#
$plantuml = "plantuml.jar"
$path = gci env:JAVA_HOME
$jarpath = ($path.value) + ("\..\ext\")

if (${file} -eq "") {
    $files = gci "*.txt"
    foreach ($filename in $files) {
#        Write-host ${filename}.basename
        if (${type} -eq "uml") {
            & java -jar ${jarpath}${plantuml} "-t${format}" -o "out/"+${filename}.basename+"."+${format} ${filename}
        } elseif (${type} -eq "dot") {
            Write-host "dot format not supported at this time"
        } else {
            Write-host "unknown format"
        }        
    }
}
break