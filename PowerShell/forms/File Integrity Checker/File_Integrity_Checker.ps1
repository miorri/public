function Show-File_Integrity_Checker {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form = New-Object 'System.Windows.Forms.Form'
	$statusstrip1 = New-Object 'System.Windows.Forms.StatusStrip'
	$groupbox4 = New-Object 'System.Windows.Forms.GroupBox'
	$buttonFile = New-Object 'System.Windows.Forms.Button'
	$textboxFile = New-Object 'System.Windows.Forms.TextBox'
	$groupbox2 = New-Object 'System.Windows.Forms.GroupBox'
	$tablelayoutpanel2 = New-Object 'System.Windows.Forms.TableLayoutPanel'
	$textboxMD5 = New-Object 'System.Windows.Forms.TextBox'
	$textboxSHA1 = New-Object 'System.Windows.Forms.TextBox'
	$textboxSHA256 = New-Object 'System.Windows.Forms.TextBox'
	$textboxSHA384 = New-Object 'System.Windows.Forms.TextBox'
	$textboxSHA512 = New-Object 'System.Windows.Forms.TextBox'
	$groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
	$tablelayoutpanel1 = New-Object 'System.Windows.Forms.TableLayoutPanel'
	$checkboxSHA512 = New-Object 'System.Windows.Forms.CheckBox'
	$checkboxMD5 = New-Object 'System.Windows.Forms.CheckBox'
	$checkboxSHA256 = New-Object 'System.Windows.Forms.CheckBox'
	$checkboxSHA384 = New-Object 'System.Windows.Forms.CheckBox'
	$checkboxSHA1 = New-Object 'System.Windows.Forms.CheckBox'
	$labelType = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelTypeVariable = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelSize = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelSizeVariable = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelDivider0 = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelDivider1 = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelName = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$labelNameVariable = New-Object 'System.Windows.Forms.ToolStripStatusLabel'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	$AppName = "File Integrity Checker"
	$AppVersion = @{
		Major = 1
		Minor = 1
		Patch = 0
		Build = 1
	}
	
	$checkboxes = @($checkboxMD5, $checkboxSHA1, $checkboxSHA256, $checkboxSHA384, $checkboxSHA512)
	$textboxes = @($textboxMD5, $textboxSHA1, $textboxSHA256, $textboxSHA384, $textboxSHA512)
	$inputItems = @($textboxFile, $buttonFile)
	$labels = @($labelType, $labelTypeVariable, $labelDivider0, $labelSize, $labelSizeVariable, $labelDivider1, $labelName, $labelNameVariable)
	
	$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$openFileDialog.Title = "Please select a file"
	$openFileDialog.Filter = "All Files (*.*)|*.*"
	
	$script:Fresh = $true
	
	
	
	$buttonFile_Click={
	    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
			$fileObject = $openFileDialog.FileName
	    }
		
		if($fileObject.Length -gt 0)
		{
			if($fresh)
			{
				$labels | ForEach-Object {
					$_.ForeColor = 'Black'
				}
				
				$script:Fresh = $false
			}
			
			$fileObject = Get-Item -LiteralPath $fileObject
			
			$labelNameVariable.Text = $fileObject.BaseName
			$labelTypeVariable.Text = $fileObject.Extension
			
			if ($fileObject.Length -ge 1GB)
			{
				$labelSizeVariable.Text = "{0:N2} GB" -f ($fileObject.Length / 1GB)
			}
			elseif ($fileObject.Length -ge 1MB)
			{
				$labelSizeVariable.Text = "{0:N2} MB" -f ($fileObject.Length / 1MB)
			}
			elseif ($fileObject.Length -ge 1KB)
			{
				$labelSizeVariable.Text = "{0:N2} KB" -f ($fileObject.Length / 1KB)
			}
			else
			{
				$fileObject.Length
			}
			
			$textboxFile.Text = $fileObject.FullName
		}
	}
	
	function Generate-FileHashes {
		if($textboxFile.Text.Length -gt 0)
		{	
			if(Test-Path -LiteralPath $textboxFile.Text -Type Leaf)
			{
				$inputItems | ForEach-Object { $_.Enabled = $false}
				foreach($checkbox in $checkboxes)
				{
					if($checkbox.Checked -eq $true)
					{
						$form.Refresh()
						$algorithm = $checkbox.Text
						$textbox = $textboxes | Where-Object -Property Name -Like "*$algorithm*"
						if($textbox.Text.Length -eq 0)
						{
							$textbox.Text = (Get-FileHash -LiteralPath $textboxFile.Text -Algorithm $algorithm).Hash
						}
					}
				}
				
				$inputItems | ForEach-Object { $_.Enabled = $true}
			}
		}
	}
	function Set-CheckBoxColor {
		param(
			[parameter(Mandatory=$true)]
			$CheckboxObject
		)
		
		if($CheckboxObject.Checked)
		{
			$CheckboxObject.BackColor = [System.Drawing.SystemColors]::ActiveCaption
		}
		else
		{
			$CheckboxObject.BackColor = [System.Drawing.SystemColors]::Control
		}
	}
	
	$textboxFile_TextChanged={
		$textboxes | ForEach-Object {$_.Text = ""}
		Generate-FileHashes	
	}
	
	$checkboxMD5_CheckedChanged = { Set-CheckBoxColor $checkboxMD5;  Generate-FileHashes }
	$checkboxSHA1_CheckedChanged= { Set-CheckBoxColor $checkboxSHA1; Generate-FileHashes }
	$checkboxSHA256_CheckedChanged= { Set-CheckBoxColor $checkboxSHA256; Generate-FileHashes }
	$checkboxSHA384_CheckedChanged= { Set-CheckBoxColor $checkboxSHA384; Generate-FileHashes }
	$checkboxSHA512_CheckedChanged= { Set-CheckBoxColor $checkboxSHA512; Generate-FileHashes }
	
	$textboxMD5_DoubleClick = { if ($textboxMD5.Text.Length -gt 0) { $textboxMD5.Text | Set-Clipboard } }
	$textboxSHA1_DoubleClick = { if ($textboxSHA1.Text.Length -gt 0) { $textboxSHA1.Text | Set-Clipboard } }
	$textboxSHA256_DoubleClick = { if ($textboxSHA256.Text.Length -gt 0) { $textboxSHA256.Text | Set-Clipboard } }
	$textboxSHA384_DoubleClick = { if ($textboxSHA384.Text.Length -gt 0) { $textboxSHA384.Text | Set-Clipboard } }
	$textboxSHA512_DoubleClick = { if ($textboxSHA512.Text.Length -gt 0) { $textboxSHA512.Text | Set-Clipboard } }
	
	$form_Load = {
		$versionString = "v"
		if ($AppVersion.Build -gt 0){
			$versionString = $versionString + 
				$AppVersion.Major.ToString() +
				"." +
				$AppVersion.Minor.ToString() +
				"." +
				$AppVersion.Patch.ToString() +
				"." +
				$AppVersion.Build.ToString() 
		}
		elseif ($AppVersion.Patch -gt 0){
			$versionString = $versionString +
				$AppVersion.Major.ToString() +
				"." +
				$AppVersion.Minor.ToString() +
				"." +
				$AppVersion.Patch.ToString()
		}
		elseif ($AppVersion.Minor -gt 0){
			$versionString = $versionString +
				$AppVersion.Major.ToString() +
				"." +
				$AppVersion.Minor.ToString()
		}
		elseif ($AppVersion.Major -gt 0){
			$versionString = $versionString +
				$AppVersion.Major.ToString()
		}
		
		$form.Text = "$AppName ($versionString)"
		
		$checkboxMD5.Checked = $true
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonFile.remove_Click($buttonFile_Click)
			$textboxFile.remove_TextChanged($textboxFile_TextChanged)
			$textboxMD5.remove_DoubleClick($textboxMD5_DoubleClick)
			$textboxSHA1.remove_DoubleClick($textboxSHA1_DoubleClick)
			$textboxSHA256.remove_DoubleClick($textboxSHA256_DoubleClick)
			$textboxSHA384.remove_DoubleClick($textboxSHA384_DoubleClick)
			$textboxSHA512.remove_DoubleClick($textboxSHA512_DoubleClick)
			$checkboxSHA512.remove_CheckedChanged($checkboxSHA512_CheckedChanged)
			$checkboxMD5.remove_CheckedChanged($checkboxMD5_CheckedChanged)
			$checkboxSHA256.remove_CheckedChanged($checkboxSHA256_CheckedChanged)
			$checkboxSHA384.remove_CheckedChanged($checkboxSHA384_CheckedChanged)
			$checkboxSHA1.remove_CheckedChanged($checkboxSHA1_CheckedChanged)
			$form.remove_Load($form_Load)
			$form.remove_Load($Form_StateCorrection_Load)
			$form.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$form.SuspendLayout()
	$groupbox4.SuspendLayout()
	$groupbox2.SuspendLayout()
	$tablelayoutpanel2.SuspendLayout()
	$groupbox1.SuspendLayout()
	$tablelayoutpanel1.SuspendLayout()
	$statusstrip1.SuspendLayout()
	#
	# form
	#
	$form.Controls.Add($statusstrip1)
	$form.Controls.Add($groupbox4)
	$form.Controls.Add($groupbox2)
	$form.Controls.Add($groupbox1)
	$form.AutoScaleDimensions = '6, 13'
	$form.AutoScaleMode = 'Font'
	$form.ClientSize = '404, 381'
	$form.MinimumSize = '320, 320'
	$form.Name = 'form'
	$form.SizeGripStyle = 'Hide'
	$form.Text = 'File Integrity Checker'
	$form.add_Load($form_Load)
	#
	# statusstrip1
	#
	[void]$statusstrip1.Items.Add($labelType)
	[void]$statusstrip1.Items.Add($labelTypeVariable)
	[void]$statusstrip1.Items.Add($labelDivider0)
	[void]$statusstrip1.Items.Add($labelSize)
	[void]$statusstrip1.Items.Add($labelSizeVariable)
	[void]$statusstrip1.Items.Add($labelDivider1)
	[void]$statusstrip1.Items.Add($labelName)
	[void]$statusstrip1.Items.Add($labelNameVariable)
	$statusstrip1.Location = '0, 359'
	$statusstrip1.Name = 'statusstrip1'
	$statusstrip1.Size = '404, 22'
	$statusstrip1.SizingGrip = $False
	$statusstrip1.TabIndex = 17
	$statusstrip1.Text = 'statusstrip1'
	#
	# groupbox4
	#
	$groupbox4.Controls.Add($buttonFile)
	$groupbox4.Controls.Add($textboxFile)
	$groupbox4.Anchor = 'Top, Left, Right'
	$groupbox4.Location = '12, 8'
	$groupbox4.Name = 'groupbox4'
	$groupbox4.Size = '378, 64'
	$groupbox4.TabIndex = 16
	$groupbox4.TabStop = $False
	$groupbox4.Text = 'File'
	$groupbox4.UseCompatibleTextRendering = $True
	#
	# buttonFile
	#
	$buttonFile.Anchor = 'Top, Right'
	$buttonFile.Location = '286, 19'
	$buttonFile.Name = 'buttonFile'
	$buttonFile.Size = '86, 33'
	$buttonFile.TabIndex = 11
	$buttonFile.Text = 'Browse'
	$buttonFile.UseCompatibleTextRendering = $True
	$buttonFile.UseVisualStyleBackColor = $True
	$buttonFile.add_Click($buttonFile_Click)
	#
	# textboxFile
	#
	$textboxFile.Anchor = 'Top, Left, Right'
	$textboxFile.Location = '7, 20'
	$textboxFile.Multiline = $True
	$textboxFile.Name = 'textboxFile'
	$textboxFile.Size = '273, 32'
	$textboxFile.TabIndex = 10
	$textboxFile.TextAlign = 'Center'
	$textboxFile.add_TextChanged($textboxFile_TextChanged)
	#
	# groupbox2
	#
	$groupbox2.Controls.Add($tablelayoutpanel2)
	$groupbox2.Anchor = 'Top, Bottom, Left, Right'
	$groupbox2.Location = '120, 80'
	$groupbox2.Name = 'groupbox2'
	$groupbox2.Size = '270, 268'
	$groupbox2.TabIndex = 14
	$groupbox2.TabStop = $False
	$groupbox2.Text = 'Hash'
	$groupbox2.UseCompatibleTextRendering = $True
	#
	# tablelayoutpanel2
	#
	$tablelayoutpanel2.Controls.Add($textboxMD5, 0, 0)
	$tablelayoutpanel2.Controls.Add($textboxSHA1, 0, 1)
	$tablelayoutpanel2.Controls.Add($textboxSHA256, 0, 2)
	$tablelayoutpanel2.Controls.Add($textboxSHA384, 0, 3)
	$tablelayoutpanel2.Controls.Add($textboxSHA512, 0, 4)
	$tablelayoutpanel2.ColumnCount = 1
	$System_Windows_Forms_ColumnStyle_1 = New-Object 'System.Windows.Forms.ColumnStyle' ('Percent', 100)
	[void]$tablelayoutpanel2.ColumnStyles.Add($System_Windows_Forms_ColumnStyle_1)
	$tablelayoutpanel2.Dock = 'Fill'
	$tablelayoutpanel2.Location = '3, 16'
	$tablelayoutpanel2.Name = 'tablelayoutpanel2'
	$tablelayoutpanel2.RowCount = 5
	$System_Windows_Forms_RowStyle_2 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel2.RowStyles.Add($System_Windows_Forms_RowStyle_2)
	$System_Windows_Forms_RowStyle_3 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel2.RowStyles.Add($System_Windows_Forms_RowStyle_3)
	$System_Windows_Forms_RowStyle_4 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel2.RowStyles.Add($System_Windows_Forms_RowStyle_4)
	$System_Windows_Forms_RowStyle_5 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel2.RowStyles.Add($System_Windows_Forms_RowStyle_5)
	$System_Windows_Forms_RowStyle_6 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel2.RowStyles.Add($System_Windows_Forms_RowStyle_6)
	$tablelayoutpanel2.Size = '264, 249'
	$tablelayoutpanel2.TabIndex = 18
	#
	# textboxMD5
	#
	$textboxMD5.Dock = 'Fill'
	$textboxMD5.Location = '3, 3'
	$textboxMD5.Multiline = $True
	$textboxMD5.Name = 'textboxMD5'
	$textboxMD5.ReadOnly = $True
	$textboxMD5.Size = '258, 43'
	$textboxMD5.TabIndex = 5
	$textboxMD5.TextAlign = 'Center'
	$textboxMD5.add_DoubleClick($textboxMD5_DoubleClick)
	#
	# textboxSHA1
	#
	$textboxSHA1.Dock = 'Fill'
	$textboxSHA1.Location = '3, 52'
	$textboxSHA1.Multiline = $True
	$textboxSHA1.Name = 'textboxSHA1'
	$textboxSHA1.ReadOnly = $True
	$textboxSHA1.Size = '258, 43'
	$textboxSHA1.TabIndex = 6
	$textboxSHA1.TextAlign = 'Center'
	$textboxSHA1.add_DoubleClick($textboxSHA1_DoubleClick)
	#
	# textboxSHA256
	#
	$textboxSHA256.Dock = 'Fill'
	$textboxSHA256.Location = '3, 101'
	$textboxSHA256.Multiline = $True
	$textboxSHA256.Name = 'textboxSHA256'
	$textboxSHA256.ReadOnly = $True
	$textboxSHA256.Size = '258, 43'
	$textboxSHA256.TabIndex = 7
	$textboxSHA256.TextAlign = 'Center'
	$textboxSHA256.add_DoubleClick($textboxSHA256_DoubleClick)
	#
	# textboxSHA384
	#
	$textboxSHA384.Dock = 'Fill'
	$textboxSHA384.Location = '3, 150'
	$textboxSHA384.Multiline = $True
	$textboxSHA384.Name = 'textboxSHA384'
	$textboxSHA384.ReadOnly = $True
	$textboxSHA384.Size = '258, 43'
	$textboxSHA384.TabIndex = 8
	$textboxSHA384.TextAlign = 'Center'
	$textboxSHA384.add_DoubleClick($textboxSHA384_DoubleClick)
	#
	# textboxSHA512
	#
	$textboxSHA512.Dock = 'Fill'
	$textboxSHA512.Location = '3, 199'
	$textboxSHA512.Multiline = $True
	$textboxSHA512.Name = 'textboxSHA512'
	$textboxSHA512.ReadOnly = $True
	$textboxSHA512.Size = '258, 47'
	$textboxSHA512.TabIndex = 9
	$textboxSHA512.TextAlign = 'Center'
	$textboxSHA512.add_DoubleClick($textboxSHA512_DoubleClick)
	#
	# groupbox1
	#
	$groupbox1.Controls.Add($tablelayoutpanel1)
	$groupbox1.Anchor = 'Top, Bottom, Left'
	$groupbox1.Location = '12, 80'
	$groupbox1.Name = 'groupbox1'
	$groupbox1.Size = '96, 268'
	$groupbox1.TabIndex = 1
	$groupbox1.TabStop = $False
	$groupbox1.Text = 'Algorithm'
	$groupbox1.UseCompatibleTextRendering = $True
	#
	# tablelayoutpanel1
	#
	$tablelayoutpanel1.Controls.Add($checkboxSHA512, 0, 4)
	$tablelayoutpanel1.Controls.Add($checkboxMD5, 0, 0)
	$tablelayoutpanel1.Controls.Add($checkboxSHA256, 0, 2)
	$tablelayoutpanel1.Controls.Add($checkboxSHA384, 0, 3)
	$tablelayoutpanel1.Controls.Add($checkboxSHA1, 0, 1)
	$tablelayoutpanel1.ColumnCount = 1
	$System_Windows_Forms_ColumnStyle_7 = New-Object 'System.Windows.Forms.ColumnStyle' ('Percent', 100)
	[void]$tablelayoutpanel1.ColumnStyles.Add($System_Windows_Forms_ColumnStyle_7)
	$tablelayoutpanel1.Dock = 'Fill'
	$tablelayoutpanel1.Location = '3, 16'
	$tablelayoutpanel1.Name = 'tablelayoutpanel1'
	$tablelayoutpanel1.RowCount = 5
	$System_Windows_Forms_RowStyle_8 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_8)
	$System_Windows_Forms_RowStyle_9 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_9)
	$System_Windows_Forms_RowStyle_10 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_10)
	$System_Windows_Forms_RowStyle_11 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_11)
	$System_Windows_Forms_RowStyle_12 = New-Object 'System.Windows.Forms.RowStyle' ('Percent', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_12)
	$System_Windows_Forms_RowStyle_13 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_13)
	$System_Windows_Forms_RowStyle_14 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_14)
	$System_Windows_Forms_RowStyle_15 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_15)
	$System_Windows_Forms_RowStyle_16 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_16)
	$System_Windows_Forms_RowStyle_17 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_17)
	$System_Windows_Forms_RowStyle_18 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_18)
	$System_Windows_Forms_RowStyle_19 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_19)
	$System_Windows_Forms_RowStyle_20 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_20)
	$System_Windows_Forms_RowStyle_21 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_21)
	$System_Windows_Forms_RowStyle_22 = New-Object 'System.Windows.Forms.RowStyle' ('Absolute', 20)
	[void]$tablelayoutpanel1.RowStyles.Add($System_Windows_Forms_RowStyle_22)
	$tablelayoutpanel1.Size = '90, 249'
	$tablelayoutpanel1.TabIndex = 17
	#
	# checkboxSHA512
	#
	$checkboxSHA512.Appearance = 'Button'
	$checkboxSHA512.BackColor = 'Control'
	$checkboxSHA512.CheckAlign = 'BottomCenter'
	$checkboxSHA512.Dock = 'Fill'
	$checkboxSHA512.FlatStyle = 'Flat'
	$checkboxSHA512.Location = '3, 199'
	$checkboxSHA512.Name = 'checkboxSHA512'
	$checkboxSHA512.Size = '84, 47'
	$checkboxSHA512.TabIndex = 4
	$checkboxSHA512.Text = 'SHA512'
	$checkboxSHA512.TextAlign = 'MiddleCenter'
	$checkboxSHA512.UseCompatibleTextRendering = $True
	$checkboxSHA512.UseVisualStyleBackColor = $False
	$checkboxSHA512.add_CheckedChanged($checkboxSHA512_CheckedChanged)
	#
	# checkboxMD5
	#
	$checkboxMD5.Appearance = 'Button'
	$checkboxMD5.CheckAlign = 'BottomCenter'
	$checkboxMD5.Dock = 'Fill'
	$checkboxMD5.FlatStyle = 'Flat'
	$checkboxMD5.Location = '3, 3'
	$checkboxMD5.Name = 'checkboxMD5'
	$checkboxMD5.Size = '84, 43'
	$checkboxMD5.TabIndex = 0
	$checkboxMD5.Text = 'MD5'
	$checkboxMD5.TextAlign = 'MiddleCenter'
	$checkboxMD5.UseCompatibleTextRendering = $True
	$checkboxMD5.UseVisualStyleBackColor = $False
	$checkboxMD5.add_CheckedChanged($checkboxMD5_CheckedChanged)
	#
	# checkboxSHA256
	#
	$checkboxSHA256.Appearance = 'Button'
	$checkboxSHA256.BackColor = 'Control'
	$checkboxSHA256.CheckAlign = 'BottomCenter'
	$checkboxSHA256.Dock = 'Fill'
	$checkboxSHA256.FlatStyle = 'Flat'
	$checkboxSHA256.Location = '3, 101'
	$checkboxSHA256.Name = 'checkboxSHA256'
	$checkboxSHA256.Size = '84, 43'
	$checkboxSHA256.TabIndex = 2
	$checkboxSHA256.Text = 'SHA256'
	$checkboxSHA256.TextAlign = 'MiddleCenter'
	$checkboxSHA256.UseCompatibleTextRendering = $True
	$checkboxSHA256.UseVisualStyleBackColor = $False
	$checkboxSHA256.add_CheckedChanged($checkboxSHA256_CheckedChanged)
	#
	# checkboxSHA384
	#
	$checkboxSHA384.Appearance = 'Button'
	$checkboxSHA384.BackColor = 'Control'
	$checkboxSHA384.CheckAlign = 'BottomCenter'
	$checkboxSHA384.Dock = 'Fill'
	$checkboxSHA384.FlatStyle = 'Flat'
	$checkboxSHA384.Location = '3, 150'
	$checkboxSHA384.Name = 'checkboxSHA384'
	$checkboxSHA384.Size = '84, 43'
	$checkboxSHA384.TabIndex = 3
	$checkboxSHA384.Text = 'SHA384'
	$checkboxSHA384.TextAlign = 'MiddleCenter'
	$checkboxSHA384.UseCompatibleTextRendering = $True
	$checkboxSHA384.UseVisualStyleBackColor = $False
	$checkboxSHA384.add_CheckedChanged($checkboxSHA384_CheckedChanged)
	#
	# checkboxSHA1
	#
	$checkboxSHA1.Appearance = 'Button'
	$checkboxSHA1.BackColor = 'Control'
	$checkboxSHA1.CheckAlign = 'BottomCenter'
	$checkboxSHA1.Dock = 'Fill'
	$checkboxSHA1.FlatStyle = 'Flat'
	$checkboxSHA1.Location = '3, 52'
	$checkboxSHA1.Name = 'checkboxSHA1'
	$checkboxSHA1.Size = '84, 43'
	$checkboxSHA1.TabIndex = 1
	$checkboxSHA1.Text = 'SHA1'
	$checkboxSHA1.TextAlign = 'MiddleCenter'
	$checkboxSHA1.UseCompatibleTextRendering = $True
	$checkboxSHA1.UseVisualStyleBackColor = $False
	$checkboxSHA1.add_CheckedChanged($checkboxSHA1_CheckedChanged)
	#
	# labelType
	#
	$labelType.ForeColor = 'DarkGray'
	$labelType.Name = 'labelType'
	$labelType.Size = '34, 17'
	$labelType.Text = 'Type:'
	#
	# labelTypeVariable
	#
	$labelTypeVariable.ForeColor = 'DarkGray'
	$labelTypeVariable.Name = 'labelTypeVariable'
	$labelTypeVariable.Size = '27, 17'
	$labelTypeVariable.Text = 'null'
	#
	# labelSize
	#
	$labelSize.ForeColor = 'DarkGray'
	$labelSize.Name = 'labelSize'
	$labelSize.Size = '30, 17'
	$labelSize.Text = 'Size:'
	#
	# labelSizeVariable
	#
	$labelSizeVariable.ForeColor = 'DarkGray'
	$labelSizeVariable.Name = 'labelSizeVariable'
	$labelSizeVariable.Size = '27, 17'
	$labelSizeVariable.Text = 'null'
	#
	# labelDivider0
	#
	$labelDivider0.ForeColor = 'DarkGray'
	$labelDivider0.Name = 'labelDivider0'
	$labelDivider0.Size = '12, 17'
	$labelDivider0.Text = '/'
	#
	# labelDivider1
	#
	$labelDivider1.ForeColor = 'DarkGray'
	$labelDivider1.Name = 'labelDivider1'
	$labelDivider1.Size = '12, 17'
	$labelDivider1.Text = '/'
	#
	# labelName
	#
	$labelName.ForeColor = 'DarkGray'
	$labelName.Name = 'labelName'
	$labelName.Size = '42, 17'
	$labelName.Text = 'Name:'
	#
	# labelNameVariable
	#
	$labelNameVariable.ForeColor = 'DarkGray'
	$labelNameVariable.Name = 'labelNameVariable'
	$labelNameVariable.Size = '27, 17'
	$labelNameVariable.Text = 'null'
	$statusstrip1.ResumeLayout()
	$tablelayoutpanel1.ResumeLayout()
	$groupbox1.ResumeLayout()
	$tablelayoutpanel2.ResumeLayout()
	$groupbox2.ResumeLayout()
	$groupbox4.ResumeLayout()
	$form.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $form.ShowDialog()

} #End Function

#Call the form
Show-File_Integrity_Checker | Out-Null
