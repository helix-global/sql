CREATE function [dbo].[WEB_GET_REV_PARAMS](@UserID int, @RevId int)
returns @res table (ID int, NAME nvarchar(300), DATATYPE int, [DESCRIPTION] ntext, UNITOFMES nvarchar(50), SYMBOL nvarchar(50), PARAMKIND int, PVALUE sql_variant, FILEBLOB image  )
as 
begin
  
  insert into @res (ID,NAME,DATATYPE,[DESCRIPTION],UNITOFMES,SYMBOL,PVALUE,PARAMKIND)
  select A.ID,P.NAME,P.DATATYPE,P.[DESCRIPTION],P.UNITSTR,P.SYMBOL,A.PVALUE,P.PARAMKIND
  from PR_REV_PARAMS A 
  left join PR_MODELTYPE_PARAMS P on P.ID = A.PARAMID
  left join PR_REVISION R on A.REVISIONID = R.ID
  where (A.REVISIONID = @RevId)
    and (R.MODELID in (select ID from dbo.PR_ACCESS_MODELS(@UserID,4,getdate())) or dbo.PR_ACCESS_PARAM(P.ID, @UserID, 1, getdate()) = 1)

  
  update @res set FILEBLOB = (select top 1 B.FILEBLOB 
                                from PR_REV_FILES B with (nolock) 
                               where B.REVISIONID = @RevId 
                                 and B.FILENAME = cast("@res".PVALUE as nvarchar(255)))
  where "@res".DATATYPE in (7,8)
  
  
  return

end