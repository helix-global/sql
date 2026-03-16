CREATE function [dbo].[COM_ZEITARBEIT_ACCESS] (@aUserID int, @aMode int)
returns @res table (ID int)
as 
begin

  declare @emplid int
  select @emplid = A.EMPLOYEEID from DEF_USERS A with (nolock) where A.ID = @aUserID

  insert into @res(ID)
  select A.ID
  from COM_ZEITARBEITREPORT A with (nolock)
  where A.EMPLID = @emplid
  
  
  if dbo.DEF_USERINGROUP5(@aUserID,'ADM',null,null,null,null) = 1
  begin  
  

	  insert into @res(ID)
	  select A.ID
	  from COM_ZEITARBEITREPORT A with (nolock)
	  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID

	  return
  end   
    
  
  if dbo.DEF_USERINGROUP5(@aUserID,'DH&VICE','ZAR',null,null,null) = 1
  begin  
  
      declare @now datetime = getdate()

	  insert into @res(ID)
	  select A.ID
	  from COM_ZEITARBEITREPORT A with (nolock)
	  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	  where A.EMPLID <> @emplid
	    and A.S_S in (2130017,2130018,2130019)  /*not_approved,approved,rejected*/
		and B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS2(@aUserID,1,@now))

  end    
  
  if dbo.DEF_USERINGROUP5(@aUserID,'HRZAR',null,null,null,null) = 1
  begin  

	  insert into @res(ID)
	  select A.ID
	  from COM_ZEITARBEITREPORT A with (nolock)
	  where A.S_S in (2130018)  /*not_approved,approved*/
  
  end

return

end