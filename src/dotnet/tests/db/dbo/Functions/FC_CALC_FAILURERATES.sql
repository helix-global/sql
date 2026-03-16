
CREATE function dbo.FC_CALC_FAILURERATES (@aCorrActionID int, @ddDelta int, @farLocation int)
returns @failureRates table 
  (
    FDATE date not null
   ,MTID int not null
   ,MODELID int not null
   ,FACODE int not null
   ,FCODE int            
   ,FCOUNT int
   ,FCOUNT_INT int
   ,FCOUNT_EXT int
   ,BEFORE_AFTER int
   ,ALLFAILURES int
   ,FRATE decimal(14,2) 
  ) 

BEGIN

  declare @dbeg date
  declare @dend date

  declare @FACodeID int
  declare @FCodeID int
  declare @FOperID int
  declare @iDate date /*introduction date*/
  declare @affectedModels int

  declare @allFailureRates table 
  (
    FDATE date not null
   ,MTID int not null
   ,MODELID int not null
   ,FACODE int not null
   ,FCODE int            
   ,FCOUNT int
   ,FCOUNT_INT int
   ,FCOUNT_EXT int
   ,BEFORE_AFTER int
   ,ALLFAILURES int
   ,FRATE decimal(14,2) 
  ) 

  declare @deviceFailures table 
  (
    ID int identity
   ,DEVICEID int
   ,FDATE date not null
   ,MTID int not null
   ,MODELID int not null
   ,FACODE int not null
   ,FCODE int            
   ,FCOUNT int
   ,FCOUNT_INT int
   ,FCOUNT_EXT int
   ,INT_EXT int
  ) 

  select @FACodeID = A.ANALYSISCODEID
        ,@FCodeID = A.FAILURE_CODE
        ,@FOperID = A.OPERID
        ,@iDate = cast(A.IDATE as date)
        ,@affectedModels = (select count(GG.MODELID) from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = A.ID)
  from FC_CORRACTIONS A with (nolock)
  where A.ID = @aCorrActionID
    
  set @ddDelta = case when @ddDelta<7 then 7 else @ddDelta end;

  set @dbeg = dateadd(day,-@ddDelta,@iDate)
  set @dend = dateadd(day,@ddDelta+1,@iDate)
    
  insert into @deviceFailures (DEVICEID, FDATE, MTID, MODELID, FACODE, FCODE, FCOUNT, FCOUNT_INT, FCOUNT_EXT, INT_EXT)
  select 
    C.ID
    ,cast(O.COMPLETED_DT as date)
    ,B.TYPEID
    ,A.MODELID
    ,AA.ANALYSISCODEID
    ,BB.REPCODEID
    ,isnull(A.QUANTITY,1)
    ,case A.INT_EXT when 2 /*ext*/ then 0 else isnull(A.QUANTITY,1) end
    ,case A.INT_EXT when 2 /*ext*/ then isnull(A.QUANTITY,1) else 0 end
    ,A.INT_EXT
  from FC_REPORT A with (nolock)
  left join FC_REPORT_ANALYSIS_CODES AA with (nolock) on AA.VNESHID = A.ID
  left join FC_REPORT_CODES BB with (nolock) on BB.ID = AA.FCODE
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_DEVICE C with (nolock) on C.ID = A.DEVICEID
  left join PR_OPERATION O with (nolock) on O.DEVICEID=C.ID and O.OPERTYPEID=@FOperID and O.COMPLETED_DT is not null
  where (@affectedModels = 0 or A.MODELID in (select GG.MODELID from FC_CORRACTIONS_MODELS GG with (nolock) where GG.VNESHID = @aCorrActionID))
    and O.COMPLETED_DT is not null
    and O.COMPLETED_DT > @dbeg
    and O.COMPLETED_DT < @dend
    and A.S_S in (1000103,1000104,1000123) /*analized,approved,closed*/
      
  delete from @deviceFailures
  where ID not in (select min(ID) from @deviceFailures group by DEVICEID)
  
  insert into @allFailureRates (FDATE,MTID,MODELID,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select 
    FDATE,MTID,MODELID,FACODE,FCODE
    ,sum(FCOUNT)
    ,sum(FCOUNT_INT)
    ,sum(FCOUNT_EXT)
  from @deviceFailures A 
  group by FDATE,MTID,MODELID,FACODE,FCODE
  
  insert into @failureRates (FDATE,MTID,MODELID,FACODE,FCODE,FCOUNT,FCOUNT_INT,FCOUNT_EXT)
  select 
    FDATE,MTID,MODELID,FACODE,FCODE
    ,sum(FCOUNT)
    ,sum(FCOUNT_INT)
    ,sum(FCOUNT_EXT)
  from @deviceFailures A 
  where FACODE = @FACodeID
    and (@FCodeID is null or FCODE = @FCodeID)
    and (@farLocation is null or @farLocation<0 or INT_EXT=@farLocation)
  group by FDATE,MTID,MODELID,FACODE,FCODE 

  update @failureRates 
    set ALLFAILURES = (select sum(B.FCOUNT) 
                       from @allFailureRates B 
                       where B.FDATE = "@failureRates".FDATE
                         and B.MODELID = "@failureRates".MODELID
                      )   
   
  update @failureRates 
    set BEFORE_AFTER = case when FDATE = @iDate then 0 
                            when FDATE > @iDate then 1
                            when FDATE < @iDate then -1
                            end

update @failureRates
set FRATE = case
             when ALLFAILURES > 0 then cast(FCOUNT as decimal(2, 0)) / ALLFAILURES * 100
           end


return 

END