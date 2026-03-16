CREATE  procedure [dbo].[LDM_ASSIGN_SN]  @DeviceID int, @OperID int, @UserID int
as 
set nocount on

declare @snChMode int
declare @snChPrm nvarchar(50)
declare @snChMask nvarchar(50)
declare @snCh nvarchar(50)
declare @prowid int
declare @oldSN nvarchar(50)
declare @depID int
declare @snNmin int
declare @ModelID int
declare @sn4model int; 
select 
 @snChMode = coalesce(M.SNPMODE,T.SNPMODE,0)
,@snChPrm = coalesce(M.SNPRM,T.SNPRM)
,@sn4model = coalesce(M.SNP4MODEL,0)
,@oldSN = D.SN
,@depID = M.DEPID
,@snNmin = isnull(M.SNPMIN,0)
,@ModelID = D.MODELID
from PR_DEVICE D 
left  join PR_MODELS M with (nolock) on M.ID = D.MODELID
left  join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where D.ID = @DeviceID
  
if  CHARINDEX('not assigned',@oldSN) > 0
begin
     declare @newSNN int
     declare @newSNC nvarchar(50)
    /* 
       SNN в изделие прописыватся по предыдущему SNN + кол-во бенчей (для модулей без бенчей = 1) 
       чтобы пропустить номер на второй, возможно третий и т.д бенчи 
       Бенчи заранее пронумерованы, если в модуле 2 бенча, то номер первого бенча (четный) = номеру модуля
       В этом случае SN будет = номеру первого бенча, а SNN номеру последнего (второго) бенча
       
       Бенчи для однобенчивых и для двухбенчевых модулей разные и нумеруются раздельно, пока просто заданы диапазоны:
       1Б - больше 1 000 000
       2Б - меньше
       
       Чтобы реализовать такое ввел две метки для нумерации модулей
       
       LDM_B1 для 1Б
       LDM_B2 для 2Б
       ... на будущее ??
       
       метка пишется в SNC как обычно с целью следующего поиска, в SNN как обычно последний использованный номер
       
    */
    declare @benchCount int = 1
    
    declare @benchCount2 int
    select @benchCount2 = max(A.VALUEINT2) 
    from LDM_SETTINGS A with (nolock)
    where A.LABEL = 'chipN' 
      and  exists (select B.ID from PR_OPERATION_INSTALL B with (nolock) where B.OPERID = @OperID and B.BOMID = A.VALUEINT)
    
    if  isnull(@benchCount2,0) > 1
      set @benchCount = isnull(@benchCount2,0)
    
    set @newSNC = 'LDM_B'+ltrim(rtrim(str(@benchCount)))
                                                  
    declare @specialSNAssignMinValue int
    select @specialSNAssignMinValue = A.VALUEINT 
    from LDM_SETTINGS A with (nolock)
    where A.LABEL = 'assign_module_sn_range' 
      and A.PRM = @ModelID
      
    if @specialSNAssignMinValue is  not  null
        set @newSNC = 'SN starts from ' + convert(varchar(15),@specialSNAssignMinValue)
                            
    select @newSNN = isnull(max(B.SNN),0)+1 
    from PR_DEVICE B with (nolock) 
    left  join PR_MODELS M on M.ID = B.MODELID
    where B.SNC = @newSNC
      and M.DEPID = @depID
                              
    declare @minSNval int
    select @minSNval = dbo.LDM_SETTING_INT('operation1_minSN',@benchCount)
    
    if @specialSNAssignMinValue is  not  null
        set @minSNval = @specialSNAssignMinValue
                            
    if @newSNN < @minSNval
      set @newSNN = @minSNval  
                
    set @snCh = ltrim(rtrim(str(@newSNN)))
    
    declare @firstSNN int = @newSNN
    
    if @benchCount > 1
      set @newSNN = @newSNN - 1 + @benchCount

    update PR_DEVICE set SN = @snCh, SNC = @newSNC, SNN = @newSNN where ID = @DeviceID;
    
    declare @BenchParamID int = dbo.LDM_SETTING_INT('bench_param_id',0)
    if isnull(@BenchParamID,0) > 0
    begin
        insert into PR_OPERATION_EXT_PARAMS (GID, S_CR, S_CDT, OPERID, PARAMID, DEVICEID, BOMID, PVALUE, INDEX_STR)
        select newid(), @UserID, getdate(), A.OPERID, @BenchParamID, A.PARTID, A.BOMID, @firstSNN-1+isnull(B.VALUEINT2,1), cast(@firstSNN-1+isnull(B.VALUEINT2,1) as  nvarchar(250))
        from PR_OPERATION_INSTALL A
        left join LDM_SETTINGS B with (nolock) on B.LABEL = 'chipN' and B.VALUEINT = A.BOMID
        where A.OPERID = @OperID
          and A.BOMID in (select D.VALUEINT from LDM_SETTINGS D with (nolock) where D.LABEL = 'chipN')
    end
    
    declare @benches table (SN nvarchar(50), ID int, MODELID int, BOMID int, OPERID int)

    --create benches
    insert into PR_DEVICE (GID,S_CR,S_CDT,S_S,MODELID,SN,MAPID,REVID)
    output inserted.SN, inserted.ID, inserted.MODELID into @benches(SN, ID,MODELID)
    select 
        newid(),@UserID,getdate(),1000077/*Installed*/,B.PARTMODELID,cast(@firstSNN-1+isnull(S.VALUEINT2,1) as  nvarchar(250))
        --,(select ID from PR_MAP where GID='C9A4266A-3033-423A-AD2C-824A9966D954'  /*Solder Bench Production*/)
        ,dbo.LDM_GET_BENCH_MAPID(@ModelID,B.PARTMODELID)  /*KB2587*/
        /*,dbo.LDM_GET_BENCH_REVISION(@ModelID,B.PARTMODELID)*/  
        ,dbo.LDM_GET_BENCH_REVISION2(@ModelID,B.PARTMODELID,B.BOMID)/*KB3399*/
    from PR_DEVICE D with (nolock)
    left join PR_REVISION A with (nolock) on A.ID in (select top(1) ID from PR_REVISION A where A.MODELID = D.MODELID and A.S_S=1000017/*Approved*/ order by A.NAME desc)
    left join PR_REV_BOM2 B with (nolock) on B.REVID = A.ID
    left join LDM_SETTINGS S with (nolock) on S.VALUEINT = B.BOMID
    where D.ID = @DeviceID 
      and B.BOMID in (select A.VALUEINT from LDM_SETTINGS A with (nolock) where A.LABEL = 'benchN')

    if (select count(*) from @benches) <> @benchCount
    begin
        raiserror('Benches were not created. Check revision BOM configuration.',16,0)
        return
    end

    update B
    set BOMID=S.VALUEINT
    from @benches B
    left join LDM_SETTINGS S on cast(@firstSNN-1+isnull(S.VALUEINT2,1) as nvarchar(250))=B.SN and S.LABEL='benchN'

    --install benches into module
    insert into PR_OPERATION_INSTALL (GID,S_CR,S_CDT,OPERID,PARTID,BOMID,SN,PARTMODELID)
    select newid(),@UserID,getdate(),@OperID,B.ID,B.BOMID,B.SN,B.MODELID
    from @benches B

    declare @SetBenchParamsOperID int = dbo.LDM_SETTING_INT('bench_set_parameters_oper_id',0)
    insert into dbo.PR_OPERATION (GID,S_S,S_CR,S_CDT,DEVICEID,OPERTYPEID,COMPLETED_DT,REVOPERID)
    select newid(),1000032/*Pending*/,@UserID,getdate(),B.ID,@SetBenchParamsOperID,getdate(),(select ID from PR_MAP_OPER where GID='83F32B6E-F8BC-48FE-BD16-B608BEB86283'  /*SAC adjustment*/)
    from @benches B

    --set installed chips bench parameter
    declare @BenchChipsParamID int = dbo.LDM_SETTING_INT('bench_chips_param_id',0)
    declare @chips table (ID int, SN nvarchar(50), BENCHID int)
    insert into @chips(ID,SN,BENCHID)
    select A.PARTID, C.SN, D.ID
    from PR_OPERATION_INSTALL A with (nolock)
    left join PR_DEVICE C with (nolock) on C.ID=A.PARTID
    left join LDM_SETTINGS B with (nolock) on B.LABEL = 'chipN' and B.VALUEINT = A.BOMID
    left join PR_DEVICE D with (nolock) on D.SN=cast(@firstSNN-1+isnull(B.VALUEINT2,1) as nvarchar(50))
    left join PR_MODELS M on M.ID=D.MODELID
    where A.OPERID = @OperID
        and A.BOMID in (select D.VALUEINT from LDM_SETTINGS D with (nolock) where D.LABEL = 'chipN')
        and M.TYPEID=(select ID from PR_MODELTYPE where GID='20C235BD-1019-4F31-8A8F-8D77173A8A63'  /*Solder Bench*/)

    insert into PR_DEVICE_IN_VALUES (DEVICEID,PARAMID,PVALUE)
    select C.BENCHID,@BenchChipsParamID,cast(dbo.IDCONCAT(C.ID) as nvarchar(100))
    from @chips C
    group by C.BENCHID
                            
 end    
   
 set  nocount  off


 --ROLLBACK TRANSACTION
 --go