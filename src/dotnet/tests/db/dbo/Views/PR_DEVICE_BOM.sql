
-- KB5330:2025-06-10: Refactoring.
CREATE VIEW [dbo].[PR_DEVICE_BOM]
AS
select
   [opI].[ID]
  ,[dev].[ID] [DEVICEID]
  ,[opI].[BOMID]
  ,[opI].[PARTID]
  ,[opr].[ID]   [OPERATIONID]
  ,[opr].[COMPLETED_DT]
  ,[opr].[OPERTYPEID]
  ,[opI].[SN]
  ,[opI].[SN] [PARTID_OL]
  ,[mdl].[ID] [MODELID]
  ,[opI].[REMARK]
  ,[mdl].[NAME] [MODELNAME]
  ,isnull([opI].[PARTQUANTITY],1) [PARTQUANTITY]
  ,(select top 1 [opU].[OPERID]
    from [dbo].[PR_OPERATION_UNINSTALL] [opU]
     left join [dbo].[PR_OPERATION] [ope] on [ope].[ID]=[opU].[OPERID]
    where [opU].[INSTALLROWID]=[opI].[ID]
      and [ope].[S_S] IN (1000013, 1000019)) [UNINSTALLOPERID]
from [dbo].[PR_DEVICE] [dev]
  left join [dbo].[PR_OPERATION]         [opr] on [opr].[DEVICEID]=[dev].[ID]
  left join [dbo].[PR_OPERATION_INSTALL] [opI] on [opI].[OPERID]=[opr].[ID]
  left join [dbo].[PR_MODELS]            [mdl] on [mdl].[ID]=[opI].[PARTMODELID]
where [opI].[ID] is not null
  and [opr].[S_S] in (1000013, 1000019, 1000038, 1000116)
  and [opI].[PARTID] is not null
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'PR_DEVICE_BOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'0
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'PR_DEVICE_BOM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 205
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 243
               Bottom = 125
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FF"
            Begin Extent = 
               Top = 6
               Left = 493
               Bottom = 125
               Right = 653
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 135', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'PR_DEVICE_BOM';

