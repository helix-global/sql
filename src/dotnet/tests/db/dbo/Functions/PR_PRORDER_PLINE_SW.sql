CREATE function [dbo].[PR_PRORDER_PLINE_SW](@aOrderParamRowID int)
returns nvarchar(max)
as
begin

  declare @res nvarchar(max)

  declare @swid int, @swverid int, @swmode int
  declare @swName nvarchar(200), @swVerName nvarchar(200)
  
  select @swid = A.SWID
    , @swverid = A.SWVERID
    , @swmode = A.SWMODE
    , @swName = B.NAME
    , @swVerName = C.NAME
  from PR_PRORDER_TP A with (nolock)
  left join SW_TOOLS B with (nolock) on B.ID = A.SWID
  left join SW_TOOL_VERSIONS C with (nolock) on C.ID = A.SWVERID
  left join PR_MODELTYPE_PARAMS D with (nolock) on D.ID = A.PARAMID
  where A.ID = @aOrderParamRowID
    and D.DATATYPE = 10
    
  if @swid is null 
    return null  
    
  if @swmode = 10
    set @res = 'Specified ver.: '+@swVerName
  else if @swmode = 1
    set @res = 'Latest ver. (1st operation start): '+@swName  
  else if @swmode = 2
    set @res = 'Latest ver. (operation start): '+@swName  
    
  return @res;
end;