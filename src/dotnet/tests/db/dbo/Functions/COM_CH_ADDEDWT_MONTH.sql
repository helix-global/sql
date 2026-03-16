CREATE function [dbo].[COM_CH_ADDEDWT_MONTH] (@empId int, @year int, @month int)
returns decimal(10,2)
as

begin

    declare @addWT decimal(10,2)

    set @addWT=isnull(cast(dbo.COM_CH_ADDEDWT_MONTH_MINUTES(@empId,@year,@month) as decimal(10,2)),0) / 60

    return @addWT
end