



CREATE VIEW [dbo].[SL_MODEL_OPTIONS_V]
AS
SELECT     A.ID
            , A.GID
            , A.S_CR
            , A.S_CDT
            , A.S_MR
            , A.S_MDT
            , A.OPTIONID
            , A.MODELID
            , A.PREDEFINEDOPT
            , C.CODE
            , C.NAME
            , D.NAME AS GROUPNAME
            , A.OVERPTYPE
            , A.CUSTOM4ID
            , A.CUSTOM4GROUP
            , A.PRTYPE_OVERRIDE
            , A.PRTYPE
            , A.CMP_OUT2_OVERRIDE
            , A.CMP_OUT2
            , A.CMP_BLOCK_OVERRIDE
            , A.CMP_BLOCK
            , A.CMP_REQ_OVERRIDE
            , A.CMP_REQ
FROM         dbo.PR_MODEL_OPTIONS AS A LEFT OUTER JOIN
                      dbo.PR_MODELS AS B ON B.ID = A.MODELID LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTIONS AS C ON C.ID = A.OPTIONID LEFT OUTER JOIN
                      dbo.PR_MODELTYPE_OPTION_GR AS D ON D.ID = C.OPTGROUP
WHERE     (B.TYPEID IN
                          (SELECT     MTID
                            FROM          dbo.PR_MT4CONFIG)) AND (ISNULL(A.PREDEFINEDOPT, 0) = 0) 
                                AND (ISNULL(CASE WHEN ISNULL(A.PRTYPE_OVERRIDE,0)=1 then A.PRTYPE ELSE C.PRTYPE END, 0) IN (1, 2))
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SL_MODEL_OPTIONS_V';


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
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 247
               Bottom = 125
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 455
               Bottom = 125
               Right = 663
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 701
               Bottom = 125
               Right = 861
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
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'SL_MODEL_OPTIONS_V';

