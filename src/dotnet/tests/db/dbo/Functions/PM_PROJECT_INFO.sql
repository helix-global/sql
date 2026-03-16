CREATE function [dbo].[PM_PROJECT_INFO](@aProjID int, @aMode int)
returns nvarchar(max)
as
begin

/*
1 - Project Leader
2 - CO-Leaders
*/

declare @res nvarchar(max)

if @aMode = 1
begin
  
   select @res = B.NAME
   from PM_PROJECT A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.PROJLEAD
   where A.ID = @aProjID
   

end
else if @aMode = 2
begin

   select @res = isnull(@res,'')+ case when len(@res) > 0 then ', '+B.NAME else B.NAME end
   from PM_PROJECT_COLEADERS A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   where A.VNESHID = @aProjID


end

     
return @res  

end;