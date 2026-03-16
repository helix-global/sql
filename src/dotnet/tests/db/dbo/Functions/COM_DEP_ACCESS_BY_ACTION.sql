create function [dbo].[COM_DEP_ACCESS_BY_ACTION](@aDepID int,@aAction int,@aUser int,@aDate datetime)
returns int as 
begin

  declare @tmp int
      
  select @tmp = dbo.DEF_F_ACCESS(A.ARC,null,@aAction,@aDate,@aUser,0)
    from COM_DEPARTMENTS A with (nolock) where A.ID = @aDepID;
      
  if @tmp = 1
     return 1;      

  return 0;
end