CREATE function [dbo].[COM_CH_ADDEDWT_ONEMONTH_MINUTES] (@empId int, @year int, @month int)
returns int
as

begin

    declare @addWT decimal(10,2)

    declare @calcFrom date

    select @calcFrom=E.CH_BALANCE_FROM
        from COM_EMPLOYEE E
        where E.ID=@empId

    select @addWT=isnull(sum(datediff(minute,W.DBEG,W.DEND)),0)
        from COM_ADDED_WORKTIME W
        where W.EMPLID=@empId 
          and year(W.DBEG)=@year 
          and month(W.DBEG)=@month
          and W.DBEG >= '20210706'
          and isnull(W.OVERTIME_TYPE,0)=2
          and (@calcFrom is null or W.DBEG >= @calcFrom)

    return @addWT
end