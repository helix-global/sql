create function [dbo].[FC_FACODE_FRATE3](@aFACodeID int, @aMode int)
returns decimal(14,2) as 
begin
  /*
  расчет линейного тренда 
  алгоритм http://bookaa.ru/operatsionnyy-menedzhment/postroenie-linejnogo-trenda.html
  
  @aMode 
  1 - failure rate по отношению к произведенным в месяц
  2 - failure rate по отношению к сумме отказов в месяц
  */
  
  declare @dbeg datetime = getdate()
  set @dbeg = dateadd(year,-1,@dbeg)

  declare @Ibeg int 
  set @Ibeg = year(@dbeg) * 100 + month(@dbeg)
  

  declare @calc table (X int identity, YYYY int, MM int, Y decimal(14,2), XY decimal (18,2), X2 decimal (38,2),YT decimal(14,2))
  
  insert into @calc (YYYY, MM, Y)
  select FYEAR,FMONTH,sum(case @aMode when 1 then FRATE when 2 then FRATE_2ALLFAILURES else null end)
   from FC_FAILURERATES_FARS_FACODE A with (nolock) 
   where A.FACODE = @aFACodeID
     and A.FYEARMONTH  >= @Ibeg
   group by A.FYEAR , A.FMONTH 
   order by A.FYEAR , A.FMONTH 
   
  /*
  TODO !! большой вопрос - учитывать ли нули в расчете тренда 
  если их здесь не удалять, то нужно и в отчетах на графиках менять процедуру 
  */ 
  delete from @calc where isnull(Y,0) = 0

  update @calc set XY = Y * X, X2 = X * X
  
  declare @ccc int
  declare @sumXY decimal(38,2)
  declare @sumX2 decimal(38,2)
  declare @sumX decimal(38,2)
  declare @sumY decimal(38,2)
  declare @X_ decimal(14,2)
  declare @Y_ decimal(14,2)
  declare @X_2 decimal(38,2) 
  
  select @ccc = count(*), @sumXY = sum(XY), @sumX2 = sum(X2), @sumX = sum(X), @sumY = sum(Y) from @calc  
  
  if @ccc = 0 
    return null
  
 
  set @X_ = @sumX / @ccc 
  set @Y_ = @sumY / @ccc
  
  set @X_2 = @X_ * @X_
   
  if (@sumX2 - @ccc * @X_2) = 0
    return null
    
  declare @b decimal(38,2)
  set @b = (@sumXY - @ccc * @X_ * @Y_) / (@sumX2 - @ccc * @X_2)

  declare @a decimal(38,2)
  set @a = @Y_ - @b * @X_
  
  update @calc set YT = @a + @b * X  
    
  declare @firstYT decimal (14,2) 
  declare @lastYT decimal (14,2)   
  declare @res decimal (14,2)   
  
  select  top 1 @firstYT = YT from @calc order by X 
  select  top 1 @lastYT = YT from @calc order by X desc
    
  set @res = @lastYT - @firstYT
  
  return @res  
    
  return null;
end