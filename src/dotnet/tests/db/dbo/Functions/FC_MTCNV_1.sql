CREATE function [dbo].FC_MTCNV_1(@DepID int)
returns @res table (MTID int,CCC int)
begin

  insert into @res (MTID, CCC)
  select B.TYPEID, count(*)
  from FC_REPORT A with (nolock)
  left join PR_MODELS B on B.ID = A.MODELID
  where B.DEPID = @DepID
  group by B.TYPEID
  
  if not exists (select * from @res)
  begin
    
     insert into @res (MTID, CCC)
     select top 1 A.TYPEID,count(*)
     from PR_MODELS A
     where A.DEPID = @DepID
     group by A.TYPEID
  
  end
  
  
  return

end