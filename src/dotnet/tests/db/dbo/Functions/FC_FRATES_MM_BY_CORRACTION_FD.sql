
create function [dbo].[FC_FRATES_MM_BY_CORRACTION_FD]  (@aCorrActionID int, @mmDelta int, @aMode int)
returns @res table (FYEAR int, FMONTH int, BEFORE_AFTER int, MODELID int
                   , FCOUNT decimal(14,4), FCOUNT_INT decimal(14,4),FCOUNT_EXT decimal(14,4)
                   , PRODUCED decimal(14,4), ALLFAILURES decimal(14,4), FRATE decimal(14,2) 
                   )
BEGIN

  declare @FACodeID int
  declare @FCodeID int
  declare @iDate datetime /*introduction date*/
  declare @affectedModels int
  
  declare @begYYMM int
  declare @endYYMM int 
  declare @iYYMM int 

  select @FACodeID = A.ANALYSISCODEID
        ,@FCodeID = A.FAILURE_CODE
        ,@iDate = A.IDATE
        ,@affectedModels = (select count(GG.MODELID) from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = A.ID)
    from FC_CORRACTIONS A with (nolock)
   where A.ID = @aCorrActionID
  
  declare @tempDate datetime 
  
  set @tempDate = dateadd(month,-@mmDelta,@iDate)
  set @begYYMM = year(@tempDate) * 100 + month(@tempDate)
  
  set @tempDate = dateadd(month,@mmDelta,@iDate)
  set @endYYMM = year(@tempDate) * 100 + month(@tempDate)
  
  set @iYYMM = year(@iDate) * 100 + month(@iDate)
  
  if @FCodeID is not null
  begin
      insert into @res (FYEAR, FMONTH, MODELID, FCOUNT, FCOUNT_INT, FCOUNT_EXT, PRODUCED)
      select A.FYEAR, A.FMONTH, A.MODELID, A.FCOUNT, A.FCOUNT_INT, A.FCOUNT_EXT, A.PRODUCED_COUNT
      from FC_FAILURERATES2_FARS_FD A with (nolock)
      where A.FACODE = @FACodeID
        and A.FCODE = @FCodeID
        and (@affectedModels = 0 or A.MODELID in (select GG.MODELID from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = @aCorrActionID))
        and (A.FYEAR * 100 + A.FMONTH) >= @begYYMM
        and (A.FYEAR * 100 + A.FMONTH) <= @endYYMM
  end
  else
  begin  
      insert into @res (FYEAR, FMONTH, MODELID, FCOUNT, FCOUNT_INT, FCOUNT_EXT, PRODUCED)
      select A.FYEAR, A.FMONTH, A.MODELID, A.FCOUNT, A.FCOUNT_INT, A.FCOUNT_EXT, A.PRODUCED_COUNT
      from FC_FAILURERATES_FARS_FD A with (nolock)
      where A.FACODE = @FACodeID
        and (@affectedModels = 0 or A.MODELID in (select GG.MODELID from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = @aCorrActionID))
        and (A.FYEAR * 100 + A.FMONTH) >= @begYYMM
        and (A.FYEAR * 100 + A.FMONTH) <= @endYYMM
  end

  /* добавить те модели, которые отсутствуют в FAR но были произведены в этом месяце */
  /* TODO что делать с документами где нет записей в  FC_CORRACTIONS_MODELS  ????    */
  /* считать по всем моделям в подразделении ??                                      */
  insert into @res (FYEAR, FMONTH, MODELID, FCOUNT, FCOUNT_INT, FCOUNT_EXT, PRODUCED)
  select A.FYEAR, A.FMONTH, A.MODELID, 0, 0, 0, A.PCOUNT
  from FC_FAILURERATES_PRODUCED A with (nolock)
  where  A.MODELID in (select GG.MODELID from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = @aCorrActionID)
    and (A.FYEAR * 100 + A.FMONTH) >= @begYYMM
    and (A.FYEAR * 100 + A.FMONTH) <= @endYYMM
    and not exists (select CC.FYEAR from @res CC
                     where CC.MODELID = A.MODELID
                       and CC.FYEAR = A.FYEAR
                       and CC.FMONTH = A.FMONTH
                       )
  

  update @res set ALLFAILURES = (select sum(B.FCOUNT) 
                                   from FC_FAILURERATES_FARS_FD B with (nolock)
                                  where B.FYEAR = "@res".FYEAR
                                    and B.FMONTH = "@res".FMONTH
                                    and B.MODELID = "@res".MODELID
                                 )   

   
  update @res set BEFORE_AFTER = case when (FYEAR * 100 + FMONTH) = @iYYMM then 0 
                                      when (FYEAR * 100 + FMONTH) > @iYYMM then 1
                                      when (FYEAR * 100 + FMONTH) < @iYYMM then -1
                                      end  

  return

END