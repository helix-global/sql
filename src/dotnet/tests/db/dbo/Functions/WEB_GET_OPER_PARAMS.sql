CREATE function [dbo].[WEB_GET_OPER_PARAMS](@UserID int, @aOperID int)
returns @res table (ID int, NAME nvarchar(300), DATATYPE int, [DESCRIPTION] ntext, UNITOFMES nvarchar(50), SYMBOL nvarchar(50), PARAMKIND int, PVALUE sql_variant, FILEBLOB image  )
as 
begin



insert into @res (ID,NAME,DATATYPE,[DESCRIPTION],UNITOFMES,SYMBOL,PVALUE,PARAMKIND)
select A.ID,P.NAME,P.DATATYPE,P.[DESCRIPTION],P.UNITSTR,P.SYMBOL,A.PVALUE,P.PARAMKIND
from PR_OPERATION_PARAMS A with (nolock)
left join PR_MODELTYPE_PARAMS P with (nolock) on P.ID = A.PARAMID
left join PR_OPERATION O with (nolock) on O.ID = A.OPERID
where A.OPERID = @aOperID
  and P.ID in (select PARAMID from dbo.WEB_ACCESSED_PARAMETERS(@UserID,O.DEVICEID))

update @res set FILEBLOB = (select top 1 A.FILEBLOB from PR_OPERATION_FILES A with (nolock) where A.OPERATIONID = @aOperID and A.FILENAME = cast("@res".PVALUE as nvarchar(255)) collate database_default)
where "@res".DATATYPE in (7,8)


return

end