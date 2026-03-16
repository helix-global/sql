CREATE function [dbo].[COM_CH_BALANCE_MONTH] (@empId int, @year int, @month int)
returns decimal(10,2)
as

begin
    declare @ret decimal(10,2)
    
    set @ret = isnull(CAST(dbo.COM_CH_BALANCE_MONTH_MINUTES(@empId,@year,@month) as decimal(10,2))/60,0)

    return @ret
end