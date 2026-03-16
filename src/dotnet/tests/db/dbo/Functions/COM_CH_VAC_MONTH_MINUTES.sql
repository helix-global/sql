CREATE function [dbo].[COM_CH_VAC_MONTH_MINUTES] (@empId int, @year int, @month int)
returns int
as
begin

    declare @shAbs decimal(10,2)

	declare @calcFrom date

	select @calcFrom=E.CH_BALANCE_FROM
		from COM_EMPLOYEE E
		where E.ID=@empId
	
	declare @t table (ID int, MIINUTES int, WTURN int)

	insert into @t (ID, WTURN)
	select distinct V.ID, T.WTURN
        from COM_VACATION V
			left JOIN COM_TURNS T on cast(V.DBEG as date)=cast(T.DD as date) and V.EMPLID=T.EMPLID	
        where V.EMPLID=@empId 
          and year(V.DBEG)=@year 
          and month(V.DBEG)<=@month
          and V.DBEG >= '20210706'
          and V.VACATIONTYPE=30
          and V.S_S=1000141
		  and (@calcFrom is null or V.DBEG >= @calcFrom)

	update @t set MIINUTES=(select WORKMINUTES from dbo.COM_VACATION_MINUTES_BYDAYS3(ID))
		where WTURN is null

	update @t set MIINUTES=(select WORKMINUTES from dbo.COM_VACATION_MINUTES_BYDAYS2(ID))
		where WTURN is not null


		 
	select @shAbs=isnull(sum(MIINUTES),0)    
        from @t V

    return @shAbs

/*
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
          and month(V.DBEG)<=@month
          and V.DBEG >= '20210706'
          and V.VACATIONTYPE=30
          and V.S_S=1000141
          and (@calcFrom is null or V.DBEG >= @calcFrom)

    update @t set MIINUTES=(select WORKMINUTES from dbo.COM_VACATION_MINUTES_BYDAYS2(ID))
         
    select @shAbs=isnull(sum(MIINUTES),0)    
        from @t V

    return @shAbs

*/


	
end