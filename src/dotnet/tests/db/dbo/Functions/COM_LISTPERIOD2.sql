CREATE function [dbo].[COM_LISTPERIOD2](@aDate datetime, @aMode int)
returns nvarchar(100) with schemabinding as 
begin

    if cast(@aDate as date) = cast(getdate() as date) 
       return 'Today' 

    return convert(nvarchar,@aDate,104)
              
end