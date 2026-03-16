CREATE function [dbo].[COM_CH_BALANCE] (@empId int, @year int, @vacId int)
returns decimal(10,2)
as

begin
    declare @bal decimal(10,2)

	set @bal = isnull(CAST(dbo.COM_CH_BALANCE_MINUTES(@empId,@year,@vacId) as decimal(10,2))/60,0)
                
    return @bal
end