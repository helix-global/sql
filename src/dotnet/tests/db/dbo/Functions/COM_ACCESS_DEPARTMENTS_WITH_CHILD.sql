CREATE function [dbo].[COM_ACCESS_DEPARTMENTS_WITH_CHILD] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin

insert into @res (ID) 
select A.ID from COM_DEPARTMENTS A with (nolock) 
where dbo.COM_DEP_ACCESS(null,A.ID,@aMode,@aUserID,@aDate) = 1 
  and isnull(A.DISABLED,0) <> 1

if dbo.DEF_USERINGROUP4(@aUserID,'LA',@aDate) = 1
begin
  insert into @res (ID) 
  select A.ID from COM_DEPARTMENTS A with (nolock) 
end

declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select a.ID 
    from @res d cross apply
        dbo.COM_GETCHILD_DEPARTMENTS2(d.ID,1) a

insert into @res
select ID from @childDeps
except 
select ID from @res


return

end