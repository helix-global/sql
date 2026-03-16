create function [dbo].[PR_DONE_OPER_TEXT](@OperID int, @aMode int)
returns nvarchar(512) as 
begin

  if @OperID is null
    return NULL

  declare @res nvarchar(512)
  
  declare @cmpl datetime
  declare @stateName NVARCHAR(300)
  --declare @userName NVARCHAR(300)
  
  select 
     @cmpl = A.COMPLETED_DT
    ,@stateName = dbo.DEF_STATE_NAME_EN(A.S_S) 
    --,@userName = dbo.DEF_USER(A.S_MR,0) 
  from PR_OPERATION A with (nolock) 
  where A.ID = @OperID
  
  
  set @res = @stateName 
  if @cmpl is not null
    set @res = @res + '<br>' + CONVERT(nvarchar,@cmpl,104)+ ' '+CONVERT(nvarchar,@cmpl,108)
    
  --if @userName is not null
  --    set @res = @res + ' ' + @userName
  
  return @res  

end