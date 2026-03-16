create function [dbo].[EQ_WAS_TRANSFERRED] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

  insert into @res(ID)
  select distinct A.EQID
  from EQ_CHANGEDEP_T A with (nolock)
  left join EQ_CHANGEDEP B with (nolock) on B.ID = A.VNESHID
  left join EQ_EQUIPMENT C with (nolock) on C.ID = A.EQID
  where B.S_S = 2000016
    and B.TODEPID = C.DEPID
    and B.TODEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate))

return

end