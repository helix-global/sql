create function [dbo].[COM_CH_VAC_ONEMONTH] (@empId int, @year int, @month int)
returns decimal(10,2)
as
begin
    declare @shAbs decimal(10,2)
	 
	set @shAbs=isnull(cast(dbo.COM_CH_VAC_ONEMONTH_MINUTES(@empId,@year,@month) as decimal(10,2)) / 60,0)    
  
    return @shAbs
end