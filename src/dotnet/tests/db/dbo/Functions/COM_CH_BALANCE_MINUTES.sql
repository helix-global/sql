create function [dbo].[COM_CH_BALANCE_MINUTES] (@empId int, @year int, @vacId int)
returns int
as

begin
    declare @bal int, @state int, @shdur int

    select @bal = dbo.COM_CH_BALANCE_MONTH_MINUTES(@empId, @year, 12)

    if @vacId is not null
	begin

		select @state=V.S_S, @shdur=isnull(V.SHORTDURATION,0)
			from COM_VACATION V
                where V.ID=@vacId

		if @state<>1000141 --если заявка со статусом Approved, она уже попала в баланс
			set @bal= @bal-@shdur  --т.е. balance минус текущая заявка

	end
                
    return @bal
end