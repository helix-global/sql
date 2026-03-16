CREATE function [dbo].[COM_IS_SAME_OR_CHILD_DEPARTMENT](@aDepID int,@aParentDepID int)
returns int as 
begin

  if @aDepID = @aParentDepID
    return 1
    
  
  declare @dep int
  declare @iii int
  set @iii = 1
  set @dep = @aDepID
  
  while (1=1)
  begin
     
       
     select @dep = A.PARENTDEPARTMENT from COM_DEPARTMENTS A with (nolock) where A.ID = @dep
     if @dep is null 
       return 0;
       
     if (@dep = @aParentDepID)
       return 1
     
     set @iii = @iii + 1
     if @iii > 100
       return 0;   
    
  end  

  return 0;
end