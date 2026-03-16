create function [dbo].[PR_REV2_FILES_VIS](@aCR int, @FileID int, @UserID int, @onDate datetime)
returns int as 
begin

  if (@aCR = @UserID)
     return 1

  
  if exists 
  (
  select A.ID
  from PR_REV_FILES A
  left join PR_REVISION B on B.ID = A.REVISIONID
  left join PR_REV_PARAMS D on D.REVISIONID = B.ID 
  left join PR_MODELTYPE_PARAMS MP on MP.ID = D.PARAMID
  where A.ID = @FileID
    and MP.DATATYPE in (7,8)
    and A.FILENAME = cast(D.PVALUE as nvarchar(300))
  )
    return 1;
  
  
  return 0;  

end