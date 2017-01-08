
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.String")

# Declarations
$strSQL = New-Object System.String("INSERT INTO Health.DailyDetail (ObsDate, NDB_No, Amount, Measure, Meal) Values ('7/4/1776', {0}, {1});")

# Load the form and set size and position
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Food Entry Form"
$objForm.Size = New-Object System.Drawing.Size(300,250) 
$objForm.StartPosition = "CenterScreen"

<#
 $objForm.KeyPreview = $True
#$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
#>

# Add the OK and Cancel Buttons
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,130)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"

####
# Add the click method
####
$OKButton.Add_Click(
    {
 #       $message = $strSQL.Format($strSQL, $objNDB_NoText.Text, $objAmountText.Text);
 #       $objForm.Close()
        $objMeasureText.Text = $objNDB_NoText.Text;
    })
# Add the button
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,130)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

# Add the labels
$objLabel1 = New-Object System.Windows.Forms.Label
$objLabel1.Location = New-Object System.Drawing.Size(10,20) 
$objLabel1.Size = New-Object System.Drawing.Size(75,20) 
$objLabel1.Text = "NDB_No:"
$objForm.Controls.Add($objLabel1) 

$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(10,45) 
$objLabel2.Size = New-Object System.Drawing.Size(75,20) 
$objLabel2.Text = "Meal:"
$objForm.Controls.Add($objLabel2)

$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Size(10,70) 
$objLabel3.Size = New-Object System.Drawing.Size(75,20) 
$objLabel3.Text = "Amount:"
$objForm.Controls.Add($objLabel3)

$objLabel4 = New-Object System.Windows.Forms.Label
$objLabel4.Location = New-Object System.Drawing.Size(10,95) 
$objLabel4.Size = New-Object System.Drawing.Size(75,20) 
$objLabel4.Text = "Measure:"
$objForm.Controls.Add($objLabel4)

# Add the text boxes
$objNDB_NoText = New-Object System.Windows.Forms.TextBox 
$objNDB_NoText.Location = New-Object System.Drawing.Size(85,20) 
$objNDB_NoText.Size = New-Object System.Drawing.Size(100,20) 
$objForm.Controls.Add($objNDB_NoText) 

$objMealText = New-Object System.Windows.Forms.TextBox 
$objMealText.Location = New-Object System.Drawing.Size(85,45) 
$objMealText.Size = New-Object System.Drawing.Size(100,20) 
$objForm.Controls.Add($objMealText) 

$objAmountText = New-Object System.Windows.Forms.TextBox 
$objAmountText.Location = New-Object System.Drawing.Size(85,70) 
$objAmountText.Size = New-Object System.Drawing.Size(100,20) 
$objForm.Controls.Add($objAmountText) 

$objMeasureText = New-Object System.Windows.Forms.TextBox 
$objMeasureText.Location = New-Object System.Drawing.Size(85,95) 
$objMeasureText.Size = New-Object System.Drawing.Size(100,20) 
$objForm.Controls.Add($objMeasureText) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
$objNDB_NoText.SetFocus
[void] $objForm.ShowDialog()

$Message