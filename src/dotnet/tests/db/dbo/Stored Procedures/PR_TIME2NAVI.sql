CREATE procedure [dbo].[PR_TIME2NAVI] @OperID int, @Mode int, @aUserID int, @aDate datetime
WITH EXECUTE AS OWNER, RECOMPILE
as 
SET nocount on

if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPM')
begin 
  exec dbo.PR_TIME2NAVI_IPM @OperID, @Mode, @aUserID, @aDate
end
else if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPGL')
begin 
  exec dbo.PR_TIME2NAVI_COMMON_D @OperID, @Mode, @aUserID, @aDate
end
else
begin 
  exec dbo.PR_TIME2NAVI_COMMON @OperID, @Mode, @aUserID, @aDate
end

SET nocount off