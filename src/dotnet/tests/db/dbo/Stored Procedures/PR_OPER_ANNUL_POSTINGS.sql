CREATE procedure [dbo].[PR_OPER_ANNUL_POSTINGS] @OperID int, @aUserID int, @aDate datetime
WITH EXECUTE AS OWNER, RECOMPILE
as 
SET nocount on

if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPM')
begin 
  exec dbo.PR_OPER_ANNUL_POSTINGS_IPM @OperID, @aUserID, @aDate
end
else
begin 
  exec dbo.PR_OPER_ANNUL_POSTINGS_COMMON @OperID, @aUserID, @aDate
end

SET nocount off