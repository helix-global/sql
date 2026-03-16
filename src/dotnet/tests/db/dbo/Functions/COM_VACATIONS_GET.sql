CREATE function [dbo].[COM_VACATIONS_GET] (@aUserID int, @dBeg datetime, @dEnd datetime)
returns @res table (ID int)
as 
begin

	declare @deps table (ID int not null)

	if dbo.DEF_USERINGROUP4(@aUserID,'HR',getdate()) = 1 --KB945
	begin
		insert into @deps (ID)
		select ID from COM_DEPARTMENTS with(nolock)
	end
	else 
	begin
		insert into @deps (ID)
		select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,11,getdate())
	end

/*
 declare @canSeeAllDep int = 0
 if dbo.DEF_USERINGROUP4(@aUserID,'HR',getdate()) = 1 --KB945
    set @canSeeAllDep = 1
*/

  insert into @res(ID)
  select A.ID
  from COM_VACATION A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
  where A.DBEG < @dEnd
    and isnull(A.DEND,A.DBEG) >= @dBeg 
    and B.DEPID in (select ID from @deps)
    /*and (@canSeeAllDep = 1 or B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,11,getdate())))*/
    /*and dbo.COM_VACATION_ACCESS2(A.S_CR,A.S_S,A.EMPLID,@aUserID,0,getdate())=1 */
    and dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@aUserID,11,getdate())=1 

return

end