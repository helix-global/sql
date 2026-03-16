CREATE FUNCTION [dbo].[clr_fc_access_report_tab]
(@UserID INT NULL, @Mode INT NULL, @Date DATETIME NULL)
RETURNS 
     TABLE (
        [ID] INT NULL)
AS
 EXTERNAL NAME [IPG.PDB.SqlServer.Objects].[UserDefinedFunctions].[clr_fc_access_report_tab]

