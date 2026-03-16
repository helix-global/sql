
CREATE VIEW [dbo].[SL_REQ_OPTIONS_V]
AS
SELECT     A.ID, A.S_CR, A.S_CDT, A.S_MR, A.S_MDT, A.MODELID, 
 A.OPTIONGRID, A.OPTIONGRID2, A.OPTIONGRID3, A.OPTIONGRID4, A.OPTIONGRID5,
 G1.NAME AS GRNAME, G2.NAME AS GR2NAME, G3.NAME AS GR3NAME, G4.NAME AS GR4NAME, G5.NAME AS GR5NAME
FROM         dbo.PR_MODEL_REQOPTIONGR AS A LEFT OUTER JOIN
                      dbo.PR_MODELS AS B ON B.ID = A.MODELID LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS G1 ON G1.ID = A.OPTIONGRID LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS G2 ON G2.ID = A.OPTIONGRID2 LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS G3 ON G3.ID = A.OPTIONGRID3 LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS G4 ON G4.ID = A.OPTIONGRID4 LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS G5 ON G5.ID = A.OPTIONGRID5
WHERE     (B.TYPEID IN
                          (SELECT     MTID
                            FROM          dbo.PR_MT4CONFIG))
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SL_REQ_OPTIONS_V';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SL_REQ_OPTIONS_V';


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
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 125
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G1"
            Begin Extent = 
               Top = 6
               Left = 447
               Bottom = 125
               Right = 607
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G2"
            Begin Extent = 
               Top = 6
               Left = 645
               Bottom = 125
               Right = 805
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "G3"
            Begin Extent = 
               Top = 6
               Left = 843
               Bottom = 125
               Right = 1003
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
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SL_REQ_OPTIONS_V';

