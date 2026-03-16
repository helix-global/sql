create function [dbo].[PR_OPERCMPLBYITEM](@OperID int, @DeviceID int)
returns datetime  as 
begin

     
    declare @res datetime
    select @res = max(A.COMPLETED_DT) from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.OPERTYPEID = @OperID
    return @res
  

end