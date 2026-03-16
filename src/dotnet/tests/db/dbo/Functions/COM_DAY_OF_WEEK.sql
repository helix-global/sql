create function [dbo].[COM_DAY_OF_WEEK] (@dd datetime)
returns int with schemabinding
as 
begin

    return (@@datefirst+datepart(weekday,@dd)-2)%7+1;
    
end