CREATE procedure [dbo].[SH_SHIP2NAVI] @ShipID int, @UserID int 
WITH EXECUTE AS OWNER, RECOMPILE
as
set nocount on

if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPM')
begin 
  exec dbo.SH_SHIP2NAVI_IPM @ShipID, @UserID
end
else
begin 
  exec dbo.SH_SHIP2NAVI_COMMON @ShipID, @UserID
end

set nocount off