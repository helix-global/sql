CREATE  VIEW [dbo].[YMA_IN_DIODES2]
AS
SELECT B.ID, B.SN, B.MODELID, M.CODE, M.NAME, B.S_CDT, 
      (SELECT  TOP (1) CAST(PVALUE AS  nvarchar(50)) AS EXPR1
        FROM  dbo.PR_DEVICE_IN_VALUES AS V WITH (nolock)
        WHERE (DEVICEID = B.ID) AND (PARAMID = 2922)
        ORDER  BY ID DESC) AS LOT,
      (SELECT  TOP (1) CAST(PVALUE AS  nvarchar(50)) AS EXPR1
        FROM  dbo.PR_DEVICE_PRIVAT_VALUES AS V2 WITH (nolock)
        WHERE (DEVICEID = B.ID) AND (PARAMID = 1)
        ORDER  BY B.ID DESC) AS YMALOT
        , dbo.PR_DEVICE_INVALUE_FLOAT(B.ID, 162) AS PRM_POUT
        , dbo.PR_DEVICE_INVALUE_FLOAT(B.ID, 163) AS PRM_VOLTAGE
        , dbo.PR_DEVICE_INVALUE_FLOAT(B.ID, 164) AS PRM_WAVELENGTH
        , dbo.PR_DEVICE_INVALUE_FLOAT(B.ID, 165) AS PRM_NA
        , dbo.PR_DEVICE_INVALUE_FLOAT(B.ID, 308) AS PRM_CURRENT
FROM dbo.PR_DEVICE AS B WITH (nolock) 
LEFT  OUTER  JOIN dbo.PR_MODELS AS M WITH (nolock) ON M.ID = B.MODELID
WHERE (B.MODELID IN (SELECT ID FROM dbo.PR_MODELS AS M WITH (nolock) WHERE (TYPEID = 9))) 
  /*AND (B.IMPPACKDEP = 196) */
   AND B.S_S in (1000010,1000085,1000086,1000030)
  AND (NOT  EXISTS (SELECT ID
                     FROM dbo.PR_OPERATION_INSTALL AS F WITH (nolock)
                    WHERE (PARTID = B.ID) AND (ID NOT  IN (SELECT INSTALLROWID FROM dbo.PR_OPERATION_UNINSTALL AS G)))
       )
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'YMA_IN_DIODES2';


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
         Configuration = "(H (2[78] 3) )"
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
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "M"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 125
               Right = 441
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'YMA_IN_DIODES2';

