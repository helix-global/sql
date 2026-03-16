CREATE FUNCTION [dbo].[COM_DAY_HOLIDAYIN](@day date, @mode int, @defaultAlias nvarchar(50))
RETURNS nvarchar(250)
AS
BEGIN
   /*перечисляет через запятую имена календарей в которых @day является выходным*/
  
	declare @res nvarchar(250) = null
	declare @def nvarchar(250) = dbo.DEF_ENUM_V_EN(1000063,'com_calendar_kind',1) 

	select @res =  case when @res is not null then @res+', ' else '' end 
	    + case when @def = dbo.DEF_ENUM_V_EN(1000063,'com_calendar_kind',A.CALENDAR) then isnull(@defaultAlias,@def)
	           else dbo.DEF_ENUM_V_EN(1000063,'com_calendar_kind',A.CALENDAR) end
	    
	from COM_CALENDAR A with (nolock)
	where A.DDAY = @day
	  and A.DAYSTATUS = 2 

	return @res

END