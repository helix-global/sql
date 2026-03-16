CREATE function [dbo].[COM_EMPLOYEE_IN_DEP2](@EmployeeID int, @DepID int, @Date datetime)
returns int
begin
  
  if exists (select A.ID 
               from COM_EMPL_PERIODS A with (nolock) 
              where A.EMPLID = @EmployeeID
                and A.DEPID = @DepID 
                and A.DBEG <= @Date 
                and (A.DEND is null or cast(A.DEND as date)>=cast(@Date as date)))
  begin
  
    return 1  
    
  end
  else
  begin 
   
   if not exists (select A.ID 
               from COM_EMPL_PERIODS A with (nolock) 
              where A.EMPLID = @EmployeeID
              )
   begin
   
       
      if exists (select A.ID
                 from COM_EMPLOYEE A with (nolock)
				where A.ID = @EmployeeID 
				  and A.DEPID = @DepID
				  and isnull(A.EMPDATE,'20000101') <= @Date
				  and isnull(A.DISSDATE,'40000101') > @Date
				  )
				  return 1
		   
   end   
  
  end        

  return 0

end