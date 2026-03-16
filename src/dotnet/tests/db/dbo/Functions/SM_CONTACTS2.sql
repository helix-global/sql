CREATE function dbo.SM_CONTACTS2 (@CustomerFromCall int, @CaseID int)
returns @res table (ID int )
as 
begin

  insert into @res (ID) values (@CustomerFromCall)
  
  insert into @res (ID) 
  select A.CUSTID
  from SM_SERVICECASE_BP A with (nolock)
  where A.VNESHID = @CaseID
    
  return

end