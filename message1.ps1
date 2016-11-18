Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "This is a Form"
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter the Environment:"
$label.Autosize = $True
$form.Controls.Add($label)
$form.ShowDialog()