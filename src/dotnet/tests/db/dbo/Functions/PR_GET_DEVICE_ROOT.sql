CREATE FUNCTION [dbo].[PR_GET_DEVICE_ROOT](@deviceId int)
RETURNS int
AS
BEGIN
  
  declare @res int

  declare @childID int
  set @childID = @deviceId
  
  ;with DEVICE_CTE as
  (
    select ID, PARENTID, 1 as lvl 
    from dbo.PR_DEVICE 
    where ID = @childID
  
    union all
  
    select D.ID, D.PARENTID, lvl+1 as lvl  
    from dbo.PR_DEVICE D
    inner join DEVICE_CTE RD on D.ID = RD.PARENTID
  )
  
  select top(1) @res = ID
  from DEVICE_CTE
  order by lvl desc
  
  return @res;

END