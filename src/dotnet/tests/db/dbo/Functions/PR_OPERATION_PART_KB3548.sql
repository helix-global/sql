CREATE function [dbo].[PR_OPERATION_PART_KB3548](@OperID int, @emplID int, @mode int)
returns decimal(12,4)
as
begin
/*
KB3548
@mode = 1
Возвращает какую часть операции выполнил @emplID на основании части времени
Если только один @emplID выполнял операцию - возвращает 1.00
в остальных случаях возвращает < 1.00 

@mode=2 
просто возвращает 1 если операцию выполнял только @emplID
*/

if @mode in (1,2)
begin

	if exists (select A.ID from PR_OPERATION_TIME A with(nolock) where A.OPERID = @OperID and A.EMPID = @emplID)
	begin

	   if exists (select A.ID from PR_OPERATION_TIME A with(nolock) where A.OPERID = @OperID and A.EMPID <> @emplID)
	   begin
	   
		  if @mode = 2
			return 0
	   
		  declare @now datetime = getdate()
		  declare @userID int = dbo.COM_USER_BY_EMPL(@emplID)

		  declare @all decimal(12,4) = dbo.PR_OPERATION_STAT_BY_USER_DEC(@OperID, 1, @now, null)
		  declare @thisEmpl decimal(12,4) = dbo.PR_OPERATION_STAT_BY_USER_DEC(@OperID, 1, @now, @userID)
	      
		  if @all > 0
			return  @thisEmpl / @all
		
		  return 0	
	   
	   end
	   
	   return 1

	end

end

return null
end;