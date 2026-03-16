CREATE function [dbo].[PR_MTYPE](@Mode varchar(10),@ID int)
returns int as 
begin
  declare @res int
  if @Mode = 'Model'
  begin
    select @res = A.TYPEID from PR_MODELS A with (nolock) where A.ID = @ID
    return @res
  end
  else if @Mode = 'Revision'
  begin
    select @res = A.TYPEID from PR_MODELS A with (nolock) 
     where A.ID = (select B.MODELID from PR_REVISION B with (nolock) where B.ID = @ID)
    return @res
  end
  else if @Mode = 'Device'
  begin
    select @res = A.TYPEID from PR_MODELS A with (nolock) 
     where A.ID = (select B.MODELID from PR_DEVICE B with (nolock) where B.ID = @ID)
    return @res
  end
  else if @Mode = 'Operation'
  begin
    select @res = A.TYPEID from PR_MODELS A with (nolock) 
     where A.ID = (select B.MODELID from PR_DEVICE B with (nolock) 
       where B.ID = (select C.DEVICEID from PR_OPERATION C with (nolock) where C.ID = @ID))
    return @res
  end
  return 0
end