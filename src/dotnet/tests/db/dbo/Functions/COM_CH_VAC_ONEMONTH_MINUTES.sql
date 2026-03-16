--AZURE06254:2026-01-26: COM_VACATION_MINUTES_BYDAYS2->COM_VACATION_MINUTES_BYDAYS3
CREATE function [dbo].[COM_CH_VAC_ONEMONTH_MINUTES] (@empId int, @year int, @month int)
returns int
as
begin
    declare @shAbs decimal(10,2)

    declare @calcFrom date

    select @calcFrom=E.CH_BALANCE_FROM
        from COM_EMPLOYEE E
        where E.ID=@empId
    
    declare @t table (ID int, MIINUTES int)

    insert into @t (ID)
    select V.ID
        from COM_VACATION V
        where V.EMPLID=@empId 
          and year(V.DBEG)=@year 
          and month(V.DBEG)=@month
          and V.DBEG >= '20210706'
          and V.VACATIONTYPE=30
          and V.S_S=1000141
          and (@calcFrom is null or V.DBEG >= @calcFrom)

    update @t set MIINUTES=(select WORKMINUTES from dbo.COM_VACATION_MINUTES_BYDAYS3(ID))
         
    select @shAbs=isnull(sum(MIINUTES),0)    
        from @t V

    return @shAbs
end