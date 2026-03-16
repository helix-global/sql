create function [dbo].EQ_MTIDS_BY_EQID(@eqid int, @UserID int)
returns @res table (ID int)
as 
begin

declare @eqtypeid int

select @eqtypeid = B.EQTYPEID
from EQ_EQUIPMENT A with (nolock)
left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
where A.ID = @eqid

  insert into @res (ID)
 select A.MTID from EQ_TYPES A with (nolock) 
  where A.ID = @eqtypeid 
    and A.MTID is not null
union 
 select B.MTID from EQ_ADD_MTID_LINKS B with (nolock) 
  where B.EQTYPEID = @eqtypeid
    and dbo.COM_DEP_ACCESS2(B.DEPID,0,@UserID,getdate()) = 1

  return
 
end