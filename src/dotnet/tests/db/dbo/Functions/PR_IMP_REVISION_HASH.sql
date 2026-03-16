CREATE function [dbo].[PR_IMP_REVISION_HASH](@RevID int, @aMode int)
returns varchar(50) as 
begin

  declare @res varchar(50)
  
  declare @value2hash nvarchar(max)
  
  select top 1 @value2hash = isnull(convert(varchar,A.S_MDT,120),'NA') + isnull(convert(varchar,B.S_MDT,120),'NA')
  from PR_REVISION A with (nolock) 
  left join PR_MAP B with (nolock) on B.ID = A.MAPID
  where A.ID = @RevID
  
  declare @lastAddTimesUpd datetime
  select @lastAddTimesUpd = max(isnull(S_MDT,S_CDT)) from PR_REV_ADD_TIMES where REVID = @RevID
  
  if @lastAddTimesUpd is not null
     set @value2hash = @value2hash + convert(varchar,@lastAddTimesUpd,120) 
  
  set @res = convert(varchar(34),HASHBYTES('MD5', @value2hash) ,1) 
  
  return @res  

end