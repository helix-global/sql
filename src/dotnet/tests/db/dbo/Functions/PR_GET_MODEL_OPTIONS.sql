CREATE function [dbo].[PR_GET_MODEL_OPTIONS] (@aModelID int,@aExOptions nvarchar(max))
returns @res table (ID int, CMP_REQ nvarchar(200), CMP_BLOCK nvarchar(200))
as 
begin


declare @ExOptTab table (ID int, CMP_OUT nvarchar(200))

insert into @ExOptTab (ID,CMP_OUT)
select A.ID, CASE WHEN ISNULL(MO.CMP_OUT2_OVERRIDE,0)=1 THEN MO.CMP_OUT2 ELSE B.CMP_OUT END
from dbo.COM_STR2TABLE_INT(@aExOptions) A
left join PR_MODELTYPE_OPTIONS B on B.ID = A.ID
left join PR_MODEL_OPTIONS MO on MO.MODELID = @aModelID and MO.OPTIONID = B.ID 

declare @mtid int
select @mtid = A.TYPEID
from PR_MODELS A 
where A.ID = @aModelID

declare @AllOUTTags table (ITEM nvarchar(max))

insert into @AllOUTTags (ITEM)
select B.ITEM
from @ExOptTab A
cross apply dbo.COM_STR2TABLE_STR(A.CMP_OUT) B

insert into @res (ID,CMP_REQ,CMP_BLOCK)
select A.ID, CASE WHEN ISNULL(B.CMP_REQ_OVERRIDE,0)=1 THEN B.CMP_REQ ELSE A.CMP_REQ END
        , CASE WHEN ISNULL(B.CMP_BLOCK_OVERRIDE,0)=1 THEN B.CMP_BLOCK ELSE A.CMP_BLOCK END
from PR_MODELTYPE_OPTIONS A
    join PR_MODELTYPE_OPTION_GR G on A.OPTGROUP=G.ID
    join PR_MODEL_OPTIONS B on A.ID=B.OPTIONID and B.MODELID = @aModelID and isnull(B.PREDEFINEDOPT,0) = 0
where G.TYPEID = @mtid

delete from @res
where CMP_REQ is not null
  and exists (select * from dbo.COM_STR2TABLE_STR("@res".CMP_REQ) B where B.ITEM not in (select N.ITEM from @AllOUTTags N)) 

delete from @res
where CMP_BLOCK is not null
  and exists (select * from dbo.COM_STR2TABLE_STR("@res".CMP_BLOCK) B where B.ITEM in (select N.ITEM from @AllOUTTags N)) 


return

end