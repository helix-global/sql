CREATE function [dbo].[PR_OPER_CAPTION](@aOperID int,@aSN nvarchar(20),@aOperName nvarchar(300))
returns nvarchar(400) as 
begin
   
  if @aOperName is not null
  begin
    if @aSN is not null 
       return @aSN + ': "'+@aOperName+'"' 
    else
       return @aOperName
  end  
  else
  begin
     declare @opername nvarchar(400)  
     declare @sn nvarchar(20)
     select
        @sn = C.SN
       ,@opername = B.NAME
     from PR_OPERATION A with (nolock)
     left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID
     left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
     where A.ID = @aOperID

     if @sn is not null
         return @sn + ': "'+@opername+'"' 
     else
         return @opername
     
  end
  
  return null
  
end