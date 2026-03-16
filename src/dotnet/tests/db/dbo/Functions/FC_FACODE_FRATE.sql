CREATE function [dbo].[FC_FACODE_FRATE](@aFACodeID int, @aMode int)
returns decimal(14,2) as 
begin
  /*
  @aMode 
  1 - failure rate по отношению к произведенным в месяц
  2 - failure rate по отношению к сумме отказов в месяц
  */

  declare @lastMM int 
  declare @lastYY int
  declare @lastFR decimal(14,2)
  
  select top 1 @lastYY = FYEAR, @lastMM = FMONTH from FC_FAILURERATES_FARS_MT A with (nolock) 
   where A.FACODE = @aFACodeID
   order by A.FYEAR desc, A.FMONTH desc

  declare @dd datetime
  set @dd = dbo.COM_ENCODE_DATE(@lastYY,@lastMM,1)
  set @dd = dateadd(month,-1,@dd)
  
  
  declare @prevMM int 
  declare @prevYY int
  declare @prevFR decimal(14,2)
  
  set @prevMM = month(@dd)
  set @prevYY = year(@dd)

  if @aMode = 1
  begin
      
	  select @lastFR = avg(A.FRATE) from FC_FAILURERATES_FARS_MT A with (nolock) 
	  where A.FYEAR = @lastYY and A.FMONTH = @lastMM and A.FACODE = @aFACodeID and A.FRATE is not null

	  select @prevFR = avg(A.FRATE) from FC_FAILURERATES_FARS_MT A with (nolock) 
	  where A.FYEAR = @prevYY and A.FMONTH = @prevMM and A.FACODE = @aFACodeID and A.FRATE is not null

  end
  else if @aMode = 2
  begin
      
	  select @lastFR = avg(A.FRATE_2ALLFAILURES) from FC_FAILURERATES_FARS_MT A with (nolock) 
	  where A.FYEAR = @lastYY and A.FMONTH = @lastMM and A.FACODE = @aFACodeID and A.FRATE_2ALLFAILURES is not null

	  select @prevFR = avg(A.FRATE_2ALLFAILURES) from FC_FAILURERATES_FARS_MT A with (nolock) 
	  where A.FYEAR = @prevYY and A.FMONTH = @prevMM and A.FACODE = @aFACodeID and A.FRATE_2ALLFAILURES is not null

  end
  
  if @prevFR is null or @lastFR is null
    return null 
  
  if @prevFR > @lastFR  
    return -1 * (@prevFR - @lastFR)
    
  if @lastFR > @prevFR
    return (@lastFR - @prevFR)
  /*
  if @prevFR > @lastFR  
    if @prevFR > 0
       return -1 * ((@prevFR - @lastFR) / @prevFR * 100)

  if @lastFR > @prevFR
    if @prevFR > 0
      return  ((@lastFR - @prevFR) / @prevFR  * 100)
  */
    
  return null;
end