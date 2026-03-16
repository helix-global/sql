CREATE FUNCTION [dbo].[COM_EMPL_ZEITREPORT_NOTIFY_TIME]
(
    @d datetime, @empId int
)
RETURNS datetime
AS
BEGIN
    /*Функция вычисляет время напоминания, если следующий рабочий день - первый рабочий день недели или первый рабочий день месяца,
    и на него взят отпуск*/

    declare @pWeekN int = (year(@d) * 100) + datepart(iso_week,@d) 

    if exists(select F.ID 
                    from COM_ZEITARBEITREPORT F with (nolock) 
                    where F.EMPLID = @empId
                      and F.WEEKN = @pWeekN
                      and F.S_S in (2130018,2130017) /*approved, applyed(not approved)*/
                      and isnull(F.MONTH_END,0) <> 1 
                  )
        return null --Time Sheet создан

     
    declare @startNextWeek datetime, @lastWorkDay datetime, @isLastWorkDay int = 0
    declare @wtId int, @isVacDay int
    declare @timeNotify datetime

    declare @i int = 1
    while datepart(weekday,dateadd(day,@i,@d))<>@@DATEFIRST and datepart(day,dateadd(day,@i,@d))<>1
    begin
    
        set @i = @i + 1

    end

    set @startNextWeek = dateadd(day,@i,@d)
    set @i = 1

    set @wtId = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@empId,@startNextWeek)

    while dbo.COM_IS_WORKDAY2(@startNextWeek,1,@wtId)=0
    begin
    
        set @startNextWeek = DATEADD(day,1,@startNextWeek)
        set @wtId = dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@empId,@startNextWeek)

    end

    set @isVacDay = dbo.COM_IS_VACATIONDAY(@startNextWeek, @empId)


    if @isVacDay>0
    begin
        set @lastWorkDay = dateadd(day,-1,@startNextWeek)

        while cast(@lastWorkDay as date)>cast(@d as date) and @isLastWorkDay=0
        begin
            if dbo.COM_IS_WORKDAY2(@lastWorkDay,1,@wtId)=1 and dbo.COM_IS_VACATIONDAY(@lastWorkDay, @empId)=0
            begin
                set @isLastWorkDay = 1
            end
            else
                set @lastWorkDay = dateadd(day,-1,@lastWorkDay)
        end

        if cast(@lastWorkDay as date) = cast(@d as date)
        begin
            if dbo.COM_IS_WORKDAY2(@lastWorkDay,1,@wtId)=0
            begin
                select top 1 @timeNotify=dateadd(minute,-15,A.DEND)
                    from COM_ADDED_WORKTIME A
                    where A.EMPLID=@empId and cast(A.DBEG as date)=cast(@lastWorkDay as date)
                    order by A.DEND
            end
            else
            begin
                select top 1 @timeNotify=dateadd(minute,-15,DEND) from dbo.COM_WORKPERIODS3(@d,@d,1,@wtId,@empId) order by DBEG desc
            end
            set @timeNotify = isnull(@timeNotify,getdate())
        end
    end

    return @timeNotify

END