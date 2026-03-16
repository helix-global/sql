
CREATE function [dbo].[WEB_GET_DEVICE_PARAMS_ALL](@UserID int, @aDeviceID int, @aRefValues int ,@aValues int, @aFiles int, @skipAccessCheck bit)
returns @res table (ID int, NAME nvarchar(300), DATATYPE int, [DESCRIPTION] ntext, UNITOFMES nvarchar(50), SYMBOL nvarchar(50), PARAMKIND int, PVALUE sql_variant, FILEBLOB image  )
as 
begin

declare @pk1 int, @pk2 int

if @aValues = 1
  set @pk1 = 1

if @aRefValues = 1
  set @pk2 = 2

insert into @res (ID,NAME,DATATYPE,[DESCRIPTION],UNITOFMES,SYMBOL,PVALUE,PARAMKIND)
select P.ID,P.NAME,P.DATATYPE,P.[DESCRIPTION],P.UNITSTR,P.SYMBOL,dbo.PR_DEVICE_PARAM(A.ID, P.ID),P.PARAMKIND
from PR_DEVICE A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
left join PR_MODELTYPE_PARAMS P with (nolock) ON P.TYPEID = B.TYPEID
where A.ID = @aDeviceID
  --and (@skipAccessCheck = 1 or P.ID in (select PARAMID from dbo.WEB_ACCESSED_PARAMETERS(@UserID,A.ID)))
  and P.PARAMKIND in (@pk1,@pk2)
  and P.DATATYPE not in (10) /*SW&T*/
  and (P.DATATYPE not in (7,8) /*File,Pict*/ or @aFiles = 1)

update @res set FILEBLOB = (select top 1 FILEBLOB from dbo.PR_DEVICE_PARAM_FILES(@aDeviceID,"@res".ID) )
where "@res".DATATYPE in (7,8)

return

end