CREATE procedure [dbo].[PR_PREPARE_DEVICE_SW] 
 @DeviceID int, @UserID int, @aDate datetime
as 
SET nocount on

  declare @RevID int
  declare @ModTypeID int  
  declare @orderRowID int

  select @RevID = D.REVID
       , @ModTypeID = M.TYPEID
       , @orderRowID = D.ORDERROWID
    from PR_DEVICE D with (nolock)
    left join PR_REVISION R with (nolock) on R.ID = D.REVID 
    left join PR_MODELS M with (nolock) on M.ID = R.MODELID 
   where D.ID = @DeviceID;

  declare @needSW table (SWID int,SWTOOLID int,SWVERID int,SWMODE int,SWEXIST int)
  
  declare @opts table (OPTID int not null)
  
  insert into @opts (OPTID) 
  select B.OPTID from PR_DEVICE_OPT B with (nolock) where B.DEVICEID = @DeviceID
  
  if @orderRowID is not null  /* sw передали с заказом */
  begin
    insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
    select A.PARAMID,A.SWID,A.SWVERID,A.SWMODE
      from PR_PRORDER_TP A with (nolock) 
      where A.OPID = @orderRowID
        and A.SWID is not null
  end  
  
  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_REV_SW A with (nolock)
   where A.REVID = @RevID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 in (select OPTID from @opts)
     and A.ONLYOPTION3 in (select OPTID from @opts)
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_REV_SW A with (nolock)
   where A.REVID = @RevID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 in (select OPTID from @opts)
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_REV_SW A with (nolock)
   where A.REVID = @RevID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 is null
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)
     
  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_REV_SW A with (nolock)
   where A.REVID = @RevID
     and A.ONLYOPTION is null 
     and A.ONLYOPTION2 is null
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_MODELTYPE_COMMON_SW A with (nolock)
    left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
   where AA.MTID = @ModTypeID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 in (select OPTID from @opts)
     and A.ONLYOPTION3 in (select OPTID from @opts)
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_MODELTYPE_COMMON_SW A with (nolock)
    left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
   where AA.MTID = @ModTypeID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 in (select OPTID from @opts)
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_MODELTYPE_COMMON_SW A with (nolock)
    left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
   where AA.MTID = @ModTypeID
     and A.ONLYOPTION in (select OPTID from @opts)
     and A.ONLYOPTION2 is null
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)
     
  insert into @needSW(SWID,SWTOOLID,SWVERID,SWMODE)
  select A.SWID,A.SWTOOLID,A.SWVERSIONID,A.SWMODE
    from PR_MODELTYPE_COMMON_SW A with (nolock)
    left join PR_MODELTYPE_COMMON AA with (nolock) on AA.ID = A.MTID
   where AA.MTID = @ModTypeID
     and A.ONLYOPTION is null 
     and A.ONLYOPTION2 is null
     and A.ONLYOPTION3 is null
     and not exists (select * from @needSW VV where VV.SWID = A.SWID)

     
   if exists (select COUNT(*) from @needSW group by SWID having COUNT(*) > 1)
   begin
     /* KB679 
     raiserror('Cannot define software & tools versions for device. Duplicated definition detected.',15,0)
     */
     declare @errT nvarchar(max)
     set @errT = 'Cannot define software & tools versions for device. Duplicated definitions: '

     select top 100 @errT = @errT + B.NAME + '; '
     from PR_MODELTYPE_PARAMS B with (nolock) 
     where B.ID in (select SWID from @needSW group by SWID having COUNT(*) > 1)
     
     raiserror(@errT,15,0)
    
     SET nocount off
     return
   end   
   
   update @needSW set SWVERID = (select max(V.ID) from SW_TOOL_VERSIONS V with (nolock) where V.TOOLID = SWTOOLID and V.S_S in (1000061))
    where SWMODE in (1,2) 
   
   if exists (select * from @needSW where SWVERID is null)
   begin
     declare @errNames nvarchar(max)
     set @errNames = ' '
     select top 100 @errNames = @errNames + B.NAME + '; '
     from @needSW A 
     left join PR_MODELTYPE_PARAMS B with (nolock) on B.ID = A.SWID
     where A.SWVERID is null
     declare @errText nvarchar(max)
     set @errText = 'Cannot define all software & tools versions for device.'
     if @errNames is not null
        set @errText = @errText + ' Error items:'+@errNames
     raiserror(@errText,15,0)
     SET nocount off
     return
   end
   
   update @needSW 
   set SWEXIST = (select G.ID from PR_DEVICE_SW G with (nolock) where G.DEVICEID = @DeviceID and G.SWID = [@needSW].SWID)
   
   insert into PR_DEVICE_SW (DEVICEID,SWID,SWVERSIONID,LASTUPDATED,AUTOADDED)
   select @DeviceID,SWID,SWVERID,GETDATE(),SWMODE
   from @needSW
   where SWEXIST is null
   
   update PR_DEVICE_SW 
      set PR_DEVICE_SW.SWVERSIONID = (select A.SWVERID from @needSW A where A.SWEXIST = PR_DEVICE_SW.ID)
         ,PR_DEVICE_SW.LASTUPDATED = GETDATE()
    where PR_DEVICE_SW.ID in (select SWEXIST from @needSW where SWMODE in (2,10)/* = 2  KB966 */)
      and PR_DEVICE_SW.DEVICEID = @DeviceID
      and PR_DEVICE_SW.SWVERSIONID <> (select A.SWVERID from @needSW A where A.SWEXIST = PR_DEVICE_SW.ID)

     /*NDA 040315 добалено удаление (если была смена опции, например)*/
     declare @needDel table (ID int)
     insert into @needDel (ID)
     select A.ID 
     from PR_DEVICE_SW A 
     where A.DEVICEID = @DeviceID
       and A.AUTOADDED = 2
       and not exists (select B.SWID from @needSW B where B.SWID = A.SWID)

     delete from PR_DEVICE_SW 
     where DEVICEID = @DeviceID
       and ID in (select B.ID from @needDel B)      

SET nocount off