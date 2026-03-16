CREATE FUNCTION [dbo].[COM_EMPLOYEE_ACCESS_TABBYDEP](@UserID int, @aMode int)
RETURNS @res TABLE (ID int)
AS
BEGIN
  /*
  до подключения площадок типа италии и польши справочник сотрудников был общим 
  чтобы, например, можно было назначить операцию любому сотруднику
  но после подключения площадок ... ??
  как минимум, площадкам уже вряд ли нужны другие площадки
  по KB4241 просили ограничить, но только для работников отдела кадров польши, а что с остальными ... ?
  + эта функция распространится и на площадки со своими базами. как там должно быть ..?
  */
  
  if dbo.DEF_USERINGROUP5(@UserID,'ADM','LA',null,null,null) = 1
  begin
	insert into @res (ID) values (-1)
  end	
  else
  begin
	  declare @DepID int  
	  
	  select @DepID = B.DEPID
	  from DEF_USERS A with(nolock)
	  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLOYEEID	  
	  where A.ID = @UserID	  
	  
	  if @DepID = 278 /*IT*/ and dbo.DEF_USERINGROUP7(@UserID,'Employee-Editors') = 1
	  begin
		insert into @res (ID) values (-1)
	  end		  
  end	  
  
  if dbo.DEF_USERINGROUP7(@UserID,'HR') = 1
  begin
  
	  declare @TopDepCode nvarchar(100)
	  declare @TopDepID int

	  
	  select @TopDepCode = C.CODE
			,@TopDepID = C.ID
	  from DEF_USERS A with(nolock)
	  left join COM_EMPLOYEE B with(nolock) on B.ID = A.EMPLOYEEID
	  left join COM_DEPARTMENTS C with(nolock) on C.ID = dbo.COM_TOP_PARENT_DEPID(B.DEPID)
	  where A.ID = @UserID
	  
	  if @TopDepCode = 'IPGPOL'
	  begin
	  
		 insert into @res (ID) select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@TopDepID,1)
		 return
	       
	  end

  end    

  insert into @res (ID) select A.ID from COM_DEPARTMENTS A with(nolock) 

  return
END