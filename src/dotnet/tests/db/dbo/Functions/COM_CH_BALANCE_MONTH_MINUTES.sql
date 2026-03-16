CREATE function [dbo].[COM_CH_BALANCE_MONTH_MINUTES] (@empId int, @year int, @month int)
returns int
as

begin
    declare @ret int
    declare @addWT int
    declare @shAbs int
    declare @inputValue int

    select @addWT=dbo.COM_CH_ADDEDWT_MONTH_MINUTES(@empId,@year,@month)

    select @shAbs=dbo.COM_CH_VAC_MONTH_MINUTES(@empId,@year,@month)

    if @year = 2021
    begin  
		select @inputValue = J.INP_VALUE * 60 from COM_CH_BALANCE_INPUT J with (nolock) where J.EMPLID = @empId
    end

    set @ret = isnull(@inputValue,0) + @addWT - @shAbs

    return @ret
end