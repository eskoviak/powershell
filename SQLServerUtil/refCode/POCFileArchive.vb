    Public Sub PurchaseOrderContainerArchiveReceivedPOs(ByRef io_errorFlg As Boolean)
        Static lastArchived As Date = Date.MinValue
        If lastArchived.Date = Now.Date Then
            Exit Sub
        End If

        Dim emailAdditionalNameValuePairList As New NameValuePair.List_c()
        Dim dbi As Common.ConnectionStringInfo_c = Common.GetConnectionStringInfo(AppConfigDefinition.PurchaseOrderContainer_ConnectionString)
        emailAdditionalNameValuePairList.Add("SQL Server", dbi.Server)
        emailAdditionalNameValuePairList.Add("Database", dbi.Database)

        MyBase.a_StatusStripSet("Archiving Closed POs off the Purchase Order Container File")
        SQLServer.SetAppRole("PurchaseOrderContainerAppRole", "POContainer")
        ProcessSetCurrent(Process_e.Archive_Yantian_Container_File)
        Dim scp As New SQLServer.SQLCallParameters("PurchaseOrderList", CommandType.StoredProcedure, False)
        Dim as400Conn As iDB2Connection = Nothing
        Dim sqlConn As SqlConnection = Nothing

        Try
            sqlConn = SQLServer.GetConnection(True, AppConfigDefinition.PurchaseOrderContainer_ConnectionString)

            Dim prevPONum As String = String.Empty
            Dim entirePOWasArchivedFlg As Boolean = False
            Dim as400POsDT As DataTable = Nothing
            Dim as400POsDD As PODetailFromAS400_dd = Nothing
            Dim poItemNumListDT As DataTable = GetPurchaseOrderItemNumListDataTable(sqlConn)
            Dim poItemNumListDR As DataRow
            Dim poItemNumListDD As New POItemNumList_dd()
            MyBase.a_StatusStripProgressBarValue = 0
            MyBase.a_StatusStripProgressBarMaximum = poItemNumListDT.Rows.Count
            ListViewItemCountSetValue(CountType_e.Total_Records, poItemNumListDT.Rows.Count)
            CreateResultListViewItem("All", False, String.Format("Attempting to Archive {0} Purchase Order Container Records", CountListViewGetValueForType(CountType_e.Total_Records, CountColumn_e.Count)))
            ' Always call Read before accessing data.

            For Each poItemNumListDR In poItemNumListDT.Rows
                poItemNumListDD.DataRow = poItemNumListDR

                If as400Conn Is Nothing Then
                    as400Conn = AS400.IBMDotNetDriver.a_DBGetNewConnection(Me)
                End If
                as400POsDT = LoadPurchaseOrderDTFromAS400(as400Conn, prevPONum, poItemNumListDD.PurchaseOrderNum)

                If poItemNumListDD.PurchaseOrderNum <> prevPONum Then
                    If prevPONum <> String.Empty Then
                        ListViewItemCountIncrementValue(CountType_e.Number_of_POs)
                    End If
                    entirePOWasArchivedFlg = False
                End If
                prevPONum = poItemNumListDD.PurchaseOrderNum
                If entirePOWasArchivedFlg Then
                    ListViewItemCountIncrementValue(CountType_e.Archived)
                    'Do Nothing
                ElseIf PODetailFromAS400_dd.EntirePOIsReceivedFlg(as400POsDT) Then
                    ListViewItemCountIncrementValue(CountType_e.POs_Closed)
                    ListViewItemCountIncrementValue(CountType_e.Archived)
                    If (AppConfigDefinition.PurchaseOrderContainer_TurnOffSQLUpdates) Then
                        MyBase.a_WriteToLogFile(RecDesc_POContainerArchive(poItemNumListDD.PurchaseOrderNum, poItemNumListDD.TotalContainerCountForPO), String.Format("Archive & Delete by PO:{0}", poItemNumListDD.PurchaseOrderNum), False, "PurchaseOrderContainer_TurnOffSQLUpdates is set to True in the Config File so no updates occurred", "")
                    Else
                        ArchivePurchaseOrderAndItem(sqlConn, poItemNumListDD.PurchaseOrderNum, String.Empty)
                        MyBase.a_WriteToLogFile(RecDesc_POContainerArchive(poItemNumListDD.PurchaseOrderNum, poItemNumListDD.TotalContainerCountForPO), String.Format("Archive & Delete by PO:{0}", poItemNumListDD.PurchaseOrderNum), False, "Successful", "")
                    End If
                    entirePOWasArchivedFlg = True
                ElseIf PODetailFromAS400_dd.ItemIsReceivedFlg(as400POsDT, poItemNumListDD.ItemNum) Then
                        ListViewItemCountIncrementValue(CountType_e.Archived)
                        If (AppConfigDefinition.PurchaseOrderContainer_TurnOffSQLUpdates) Then
                        MyBase.a_WriteToLogFile(RecDesc_POContainerArchive(poItemNumListDD.PurchaseOrderNum, poItemNumListDD.ContainerCount, poItemNumListDD.ItemNum), String.Format("Archive & Delete by PO:{0} and Item:{1}", poItemNumListDD.PurchaseOrderNum, poItemNumListDD.ItemNum), False, "PurchaseOrderContainer_TurnOffSQLUpdates is set to True in the Config File so no updates occurred", "")
                        Else
                            ArchivePurchaseOrderAndItem(sqlConn, poItemNumListDD.PurchaseOrderNum, poItemNumListDD.ItemNum)
                        MyBase.a_WriteToLogFile(RecDesc_POContainerArchive(poItemNumListDD.PurchaseOrderNum, poItemNumListDD.ContainerCount, poItemNumListDD.ItemNum), String.Format("Archive & Delete by PO:{0} and Item:{1}", poItemNumListDD.PurchaseOrderNum, poItemNumListDD.ItemNum), False, "Successful", "")
                        End If
                Else
                        ListViewItemCountIncrementValue(CountType_e.Kept)
                    End If

                    MyBase.a_StatusStripProgressBarValue += 1
                    If a_StatusStripProgressBarValue Mod 100 = 0 _
                    OrElse a_StatusStripProgressBarValue = a_StatusStripProgressBarMaximum Then
                        Application.DoEvents()
                    End If
                    If MyBase.a_ProcessingWasCancelledFlg Then
                        MyBase.a_WriteToLogFile("All", ProcessNameReadable(Process_e.Archive_Yantian_Container_File), True, "Cancelled", "Process was cancelled by the user")
                        Exit For
                    End If
            Next
            lastArchived = Now
        Catch ex As Exception
            io_errorFlg = True
            m_emailProcessResults.Add(HTMLFormatter.Font("Error Archiving the Purchase Order Container Table - Msg:" + ex.Message, 4, Color.Red, True, False, HTMLFormatter.LineBreakLocation_e.Both))
        Finally
            MyBase.a_StatusStripClear()
            ProcessSetCurrent(Process_e.Complete)
            SQLServer.CloseConnection(sqlConn)
            AS400.IBMDotNetDriver.a_DBCloseConnection(as400Conn)
            SQLServer.SetAppRole("", "")
            If CountListViewGetCount(CountType_e.Errors) > 0 Then
                io_errorFlg = True
            End If
            CreateResultListViewItem("All", io_errorFlg, "Archive Complete")
            m_emailProcessResults.Add(EMailBuildResultHTMLTable(Process_e.Archive_Yantian_Container_File, CountListViewGetCount(CountType_e.Errors) > 0, emailAdditionalNameValuePairList))
        End Try
    End Sub