    Private Sub PurchaseOrderContainerFileLoad(ByRef io_errorFlg As Boolean)
        Dim input As TextFile = Nothing
        Dim fileExistedFlg As Boolean = False
        Dim updateSCP As New SQLServer.SQLCallParameters("PurchaseOrderContainerAddOrUpdate", CommandType.StoredProcedure, False)
        Dim emailAdditionalNameValuePairList As New NameValuePair.List_c()
        Dim newPath As String = String.Empty

        Try
            MyBase.a_StatusStripSet("Processing Purchase Order Container File")

            For Each originalFilePath As String In IO.Directory.GetFiles(AppConfigDefinition.PurchaseOrderContainer_FileLocation, AppConfigDefinition.PurchaseOrderContainer_FileSearchPattern)
                emailAdditionalNameValuePairList.Clear()
                emailAdditionalNameValuePairList.Add("File Path", originalFilePath)

                fileExistedFlg = True
                ProcessSetCurrent(Process_e.Process_Yantian_Container_File)

                If PurchaseOrderContainerFileRename(originalFilePath, newPath) Then
                    emailAdditionalNameValuePairList.Add("Renamed To", newPath)

                    Dim dbi As Common.ConnectionStringInfo_c = Common.GetConnectionStringInfo(AppConfigDefinition.PurchaseOrderContainer_ConnectionString)
                    emailAdditionalNameValuePairList.Add("SQL Server", dbi.Server)
                    emailAdditionalNameValuePairList.Add("Database", dbi.Database)
                    MyBase.a_StatusStripProgressBarValue = 0
                    MyBase.a_StatusStripProgressBarMaximum = Converter.Int32FromObject(TextFile.RecordCount(newPath))
                    ListViewItemCountSetValue(CountType_e.Total_Records, a_StatusStripProgressBarMaximum)
                    CreateResultListViewItem("All", False, String.Format("Processing {0} Purchase Order Container Records from file {1}", CountListViewGetValueForType(CountType_e.Total_Records, CountColumn_e.Count), newPath))
                    input = New TextFile(newPath)

                    Dim containerInfo As PurchaseOrderContainerFileLayout
                    SQLServer.SetAppRole("PurchaseOrderContainerAppRole", "POContainer")

                    updateSCP.Connection = SQLServer.GetConnection(True, AppConfigDefinition.PurchaseOrderContainer_ConnectionString)

                    Dim rowsProcessed As Int32 = 0
                    Do Until input.EndOfFile
                        containerInfo = New PurchaseOrderContainerFileLayout(input.ReadLine)

                        Try
                            If containerInfo.AppearsToBeAHeaderFlg Then
                                MyBase.a_WriteToLogFile(containerInfo.WorkRecord, "Header", False, "Bypassed", "First record was bypassed because it is supposed to be a header")
                                ListViewItemCountIncrementValue(CountType_e.Headings)
                            ElseIf containerInfo.PURCHASE_ORDER_NUMBER.Trim = String.Empty Then
                                MyBase.a_WriteToLogFile(containerInfo.WorkRecord, "Incomplete", False, "Bypassed", "Purchase Order Number is is empty")
                                ListViewItemCountIncrementValue(CountType_e.Bypassed_No_PO_Num)
                            ElseIf containerInfo.CONTAINER_NUMBER.Trim = String.Empty Then
                                MyBase.a_WriteToLogFile(containerInfo.WorkRecord, "Incomplete", False, "Bypassed", "Container Number is empty")
                                ListViewItemCountIncrementValue(CountType_e.Bypassed_No_Container_Num)
                            ElseIf containerInfo.POE_ARVL_DT.ToString = String.Empty Then
                                MyBase.a_WriteToLogFile(containerInfo.WorkRecord, "Incomplete", False, "Bypassed", "POE Arrival Date is empty")
                                ListViewItemCountIncrementValue(CountType_e.Bypassed_No_POE_Arrival_Date)
                            Else
                                updateSCP.StoredProcArguments = PurchaseOrderContainer.FileUpdateArguments(containerInfo)
                                If (AppConfigDefinition.PurchaseOrderContainer_TurnOffSQLUpdates) Then
                                    ListViewItemCountIncrementValue(CountType_e.Inserts)
                                    MyBase.a_WriteToLogFile(RecDesc_POContainer(containerInfo), "Insert", False, "PurchaseOrderContainer_TurnOffSQLUpdates is set to True in the Config File so no updates occurred", "")
                                Else
                                    SQLServer.ExecuteNonQuery(updateSCP, True)
                                    ListViewItemCountIncrementValue(CountType_e.Inserts)
                                    MyBase.a_WriteToLogFile(RecDesc_POContainer(containerInfo), "Insert", False, "Successful", "Record Inserted into Table")
                                End If
                            End If
                        Catch sqlEx As SqlClient.SqlException
                            Dim fields() As String = ParseDelimitedString(sqlEx.Message, Delimiter_e.Comma, TextQualifier_e.DoubleQuote)
                            If fields.Length >= 3 _
                            AndAlso fields(0) = "SQLCustomError" _
                            AndAlso fields(1) = "Duplicate" Then
                                If sqlEx.Message.Contains("Archive") Then
                                    If (sqlEx.Message.Contains(" - rows were updated")) Then
                                        ListViewItemCountIncrementValue(CountType_e.Duplicates_On_Archive_Updated)
                                    Else
                                        ListViewItemCountIncrementValue(CountType_e.Duplicates_On_Archive_Left_Alone)
                                    End If
                                Else
                                    If (sqlEx.Message.Contains(" - rows were updated")) Then
                                        ListViewItemCountIncrementValue(CountType_e.Duplicates_On_Active_Updated)
                                    Else
                                        ListViewItemCountIncrementValue(CountType_e.Duplicates_On_Active_Left_Alone)
                                    End If
                                End If
                                MyBase.a_WriteToLogFile(RecDesc_POContainer(containerInfo), "Insert", True, "Duplicate", sqlEx.Message.Replace(",", " "))
                            Else
                                ListViewItemCountIncrementValue(CountType_e.Errors)
                                MyBase.a_WriteToLogFile(RecDesc_POContainer(containerInfo), "Insert", False, "Error", sqlEx.Message)
                            End If
                        Catch ex As Exception
                            ListViewItemCountIncrementValue(CountType_e.Errors)
                            MyBase.a_WriteToLogFile(RecDesc_POContainer(containerInfo), "Insert", True, "Error", ex.Message)
                        Finally
                            UpdateRunTime()
                            rowsProcessed += 1
                            If rowsProcessed Mod 100 = 0 _
                            OrElse rowsProcessed = a_StatusStripProgressBarMaximum Then
                                Application.DoEvents()
                                a_StatusStripProgressBarValue = rowsProcessed
                            End If
                        End Try
                        If MyBase.a_ProcessingWasCancelledFlg Then
                            MyBase.a_WriteToLogFile("All", ProcessNameReadable(Process_e.Process_Yantian_Container_File), True, "Cancelled", "Process was cancelled by the user")
                            Exit For
                        End If
                    Loop

                    CreateResultListViewItem("All", io_errorFlg, String.Format("Complete - File Path:{0} {1}", newPath, ProcessStatisticString))
                End If

                ProcessSetCurrent(Process_e.Complete)
                If CountListViewGetCount(CountType_e.Errors) > 0 Then
                    io_errorFlg = True
                End If
                m_emailProcessResults.Add(EMailBuildResultHTMLTable(Process_e.Process_Yantian_Container_File, CountListViewGetCount(CountType_e.Errors) > 0, emailAdditionalNameValuePairList))
            Next
        Catch ex As Exception
            io_errorFlg = True
            CreateResultListViewItem("All", io_errorFlg, String.Format("Complete - File Path:{0} {1}", newPath, ProcessStatisticString))
            m_emailProcessResults.Add(HTMLFormatter.Font(String.Format("Error Loading the File {0} Into Purchase Order Container Table - Msg:{1}", newpath, ex.Message), 4, Color.Red, True, False, HTMLFormatter.LineBreakLocation_e.Both))
            m_emailProcessResults.Add(EMailBuildResultHTMLTable(Process_e.Process_Yantian_Container_File, CountListViewGetCount(CountType_e.Errors) > 0, emailAdditionalNameValuePairList))
        Finally
            ProcessSetCurrent(Process_e.Complete)
            SQLServer.CloseConnection(updateSCP.Connection)
            TextFile.Close(input)

            If fileExistedFlg Then
                MyBase.a_StatusStripClear()
                SQLServer.SetAppRole("", "")
            End If
        End Try
    End Sub