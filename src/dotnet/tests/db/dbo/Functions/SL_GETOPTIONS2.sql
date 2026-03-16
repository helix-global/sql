CREATE function [dbo].[SL_GETOPTIONS2] (@aModelID int,@aExOptions nvarchar(max))
returns @res table (ID int, CMP_REQ nvarchar(200), CMP_BLOCK nvarchar(200))
as 
begin

declare @ExOptTab table (ID int, CMP_OUT nvarchar(200), CMP_OUT2 nvarchar(200))

insert into @ExOptTab (ID,CMP_OUT,CMP_OUT2)
select A.ID, B.CMP_OUT, MO.CMP_OUT2
from dbo.COM_STR2TABLE_INT(@aExOptions) A
left join SL_OPTIONS B on B.ID = A.ID
left join SL_MODEL_OPTIONS MO on MO.MODELID = @aModelID and MO.OPTIONID = B.ID 

declare @mtid int
select @mtid = A.TYPEID
from SL_MODELS A 
where A.ID = @aModelID

declare @AllOUTTags table (ITEM nvarchar(max))

insert into @AllOUTTags (ITEM)
select B.ITEM
from @ExOptTab A
cross apply dbo.COM_STR2TABLE_STR(A.CMP_OUT) B

insert into @AllOUTTags (ITEM)
select B.ITEM
from @ExOptTab A
cross apply dbo.COM_STR2TABLE_STR(A.CMP_OUT2) B


insert into @res (ID,CMP_REQ,CMP_BLOCK)
select A.ID,A.CMP_REQ,A.CMP_BLOCK 
from SL_OPTIONS A
where A.TYPEID = @mtid
  and A.ID in (select B.OPTIONID from SL_MODEL_OPTIONS B where B.MODELID = @aModelID and isnull(B.PREDEFINEDOPT,0) = 0)

delete from @res
where CMP_REQ is not null
  and exists (select * from dbo.COM_STR2TABLE_STR("@res".CMP_REQ) B where B.ITEM not in (select N.ITEM from @AllOUTTags N)) 

delete from @res
where CMP_BLOCK is not null
  and exists (select * from dbo.COM_STR2TABLE_STR("@res".CMP_BLOCK) B where B.ITEM in (select N.ITEM from @AllOUTTags N)) 


return

end