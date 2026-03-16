CREATE function [dbo].[CS_HPLASER_ACCESS](@aUserID int)
returns @res table (ID int )
as 
begin

  declare @depID int
  
  select @depID = B.DEPID 
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where A.ID = @aUserID
  
  
 insert into @res (ID) 
 select distinct A.CUSTID 
 from CS_HPLASER_SUB_PERM_T A with (nolock)
 left join CS_HPLASER_SUB_PERM B with (nolock) on B.ID = A.VNESHID
 where B.DEPID = @depID
   and B.ACCESSMODE = 1 /*specified customers*/
   and B.S_S = 2000001 /*approved*/
  
  
  if exists (select B.ID from CS_HPLASER_SUB_PERM B with (nolock)
                        where B.DEPID = @depID
                          and B.ACCESSMODE = 2 /*all*/
                          and B.S_S = 2000001 /*approved*/
                     )
  begin                      
     insert into @res (ID)
     select A.ID from COM_CUSTOMER A with (nolock)
  end
  else if @aUserID = 3
  begin
     insert into @res (ID) 
     select A.ID from COM_CUSTOMER A with (nolock)
  end
  
  return 
 
end