create function [dbo].[FC_HUMANERRORS_BY_FARID] (@aFarID int)
returns @res table (ID int)
as 
begin

  declare @modelID int
  declare @itemID int
  declare @SN nvarchar(50)
  
  select @modelID = A.MODELID
       , @itemID = A.DEVICEID
       , @SN = A.SN
  from FC_REPORT A with (nolock)
  where A.ID = @aFarID
    

  if (@itemID is not null)
  begin
     insert into @res (ID)
     select A.ID 
     from FC_HUMANERROR A with (nolock)
     where A.REPORTID in (select B.ID from FC_REPORT B with (nolock) where B.MODELID = @modelID and B.DEVICEID = @itemID) 
  end
  else
  begin
     insert into @res (ID)
     select A.ID 
     from FC_HUMANERROR A with (nolock)
     where A.REPORTID in (select B.ID from FC_REPORT B with (nolock) where B.MODELID = @modelID and B.SN = @SN) 
  end
  
  return
  
end