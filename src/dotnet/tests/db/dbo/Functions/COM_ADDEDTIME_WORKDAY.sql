CREATE function [dbo].[COM_ADDEDTIME_WORKDAY] (@addedID int, @emplID int, @dbeg datetime)
returns date
as
begin
    /*KB3418 
    определяет к какому рабочему дню относится переработка 
    в основном относится к переработкам, у которых время начала после полуночи
    */

    declare @res date
    
    declare @dbegDD date = cast(@dbeg as date)
    
    if datepart(hour,@dbeg) < 9
    begin
    
       /*если есть установленная смена, относящаяся к рабочему дню "вчера" 
         и заканчивающаяся поблизости от начала переработки (+-2 часа)         
         по считать что переработка относится к рабочему дню этой смены 
        */
        declare @workday date
        
	    declare @wtIddd int
		select @wtIddd=dbo.COM_EMPLOYEE_WORKTIME_BY_DATE(@emplID,@dbeg)

        
        select top 1 @workday = A.WORKDAY 
          from dbo.COM_TURNS_AROUND(@dbeg,@wtIddd,@emplID) A
         where A.ACTIVATEDWTURN =1 
           and @dbeg >= A.WTURNBEG 
           and abs(datediff(hour,@dbeg,A.WTURNEND)) <= 2
           and A.WORKDAY = dateadd(day,-1,@dbegDD)
        
        if @workday is not null and @workday = dateadd(day,-1,@dbegDD)
           set @res = @workday
    
    end
	 
  
    return isnull(@res,@dbeg)
    
end