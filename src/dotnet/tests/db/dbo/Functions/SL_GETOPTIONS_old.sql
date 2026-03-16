CREATE function [dbo].[SL_GETOPTIONS_old] (@aModelID int,@aExOptions nvarchar(max))
returns @res table (ID int)
as 
begin

declare @ExOptTab table (ID int)
insert into @ExOptTab (ID)
select ID from dbo.COM_STR2TABLE_INT(@aExOptions)

declare @mtid int
select @mtid = A.TYPEID
from SL_MODELS A 
where A.ID = @aModelID

insert into @res (ID)
select A.ID 
from SL_OPTIONS A
where A.TYPEID = @mtid
  and A.ID in (select B.OPTIONID from PR_MODEL_OPTIONS B where B.MODELID = @aModelID and isnull(B.PREDEFINEDOPT,0) = 0)

delete from @res
where ID in (select A.VNESHID from PR_MODELTYPE_OPTIONS_REQ A)
  and not exists (select A.ID from PR_MODELTYPE_OPTIONS_REQ A where A.VNESHID = "@res".ID and A.REQOPTID in (select ID from @ExOptTab))
  and not exists (select A.ID from PR_MODELTYPE_OPTIONS_REQM A where A.VNESHID = "@res".ID and A.REQMODELID = @aModelID)
       
  


return

end