CREATE PROCEDURE [dbo].[MNT_NOTIFICATION_PART2] @UserID int
AS
BEGIN
  /* 
  ЧАСТЬ2: оповещение о просроченных операциях, ранее созданных по планам 
  вызывается из MNT_NOTIFICATION_FUTURE чтобы работала проверка на один запуск в день, которая там есть 
  */
  
  set nocount on

  declare @now datetime
  declare @nowDate date
  set @now = GETDATE()
  set @nowDate = CAST (@now as date)
  
  declare @expiredOpers table (OPERID int, PLANID int)
  
  insert into @expiredOpers (OPERID, PLANID)
  select  A.ID
        , A.MNT_PLANID
  from PR_OPERATION A with (nolock) 
  left join MNT_PLAN B with (nolock) on B.ID = A.MNT_PLANID
  where A.MNT_PLANID is not null
    and A.COMPLETED_DT is null 
    and A.S_S not in (1000023 /*canceled*/,1000038/*fail.processed KB4166*/,1000018/*Failure KB4214*/)
    and B.NOTIFICATIONEXP > 0
    and datediff(day,A.S_CDT,@now) >= 1
    and ( (datediff(day,A.S_CDT,@now) <= B.NOTIFICATIONEXP AND B.NOTIFICATIONEXP_EVRDAY=1)
            or
            (datediff(day,A.S_CDT,@now) = B.NOTIFICATIONEXP AND B.NOTIFICATIONEXP_EVRDAY=0) )
    and exists (select K.ID from MNT_PLAN_NOTYRCV K with (nolock) where K.VNESHID = B.ID)
    and B.S_S = 1

  declare @msgs table (EMPLID int, PLANID int, EQID int, OPERID int, MSGROW nvarchar(max))
  
  /*без оборудования */
  /* пока отключил
  insert into @msgs (PLANID,OPERID,EMPLID)
  select A.PLANID
        ,A.OPERID
        ,K.EMPLID
  from @expiredOpers A
  left join MNT_PLAN B with (nolock) on B.ID = A.PLANID
  left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
  left join MNT_PLAN_NOTYRCV K with (nolock) on K.VNESHID = B.ID
  where B.CRMODE in (1,2)
    and K.EMPLID is not null
    */
  
  /*с оборудованием */
  insert into @msgs (PLANID,OPERID,EQID,EMPLID)
  select A.PLANID
        ,A.OPERID
        ,D.EQID
        ,K.EMPLID
  from @expiredOpers A
  left join MNT_PLAN B with (nolock) on B.ID = A.PLANID
  left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
  left join MNT_PLAN_EQ D with (nolock) on D.VNESHID = B.ID and D.ID = C.MNT_PLAN_EQROW_ID
  left join MNT_PLAN_NOTYRCV K with (nolock) on K.VNESHID = B.ID
  where B.CRMODE in (3,4)
    and K.EMPLID is not null
    and D.EQID is not null

  update @msgs set MSGROW = dbo.MNT_NOTIFICATION_HTMLROW_EXP(PLANID, OPERID, EQID )
  
  declare @oneEmplID int
  declare @oneMessage nvarchar(max)
  declare @oneTable nvarchar(max)
  
  declare nxx cursor local read_only for 
  select distinct EMPLID from @msgs
  open nxx 
  WHILE 1=1
  BEGIN
    FETCH NEXT FROM nxx INTO @oneEmplID
    IF @@FETCH_STATUS<>0 BREAK;
    
    set @oneTable = ''
    set @oneMessage = 'Dear All,<br><br>The following operations were created based on maintenance plans and they are not completed yet:<br><br>'
    
    set @oneMessage = @oneMessage + '<font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @oneMessage = @oneMessage + '<tr><th>Maintenance Plan</th><th>Operation Date</th><th>Equipment Model</th><th>Equipment SN</th><th>Equipment TAG Nr.</th><th>Working Place</th><th>Department</th><th>Responsible Person</th><th>Equipment Type</th><th>Remark</th></tr>'
    
    select @oneTable = @oneTable + A.MSGROW
      from @msgs A where A.EMPLID = @oneEmplID 
    
    set @oneMessage = @oneMessage + @oneTable + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'
    
    exec MSG_SEND_TOEMPLOYEE @UserID, @oneEmplID, 'Expired Operations By Maintenance Plans', @oneMessage
    
  END
  close nxx;
  deallocate nxx;   
  

END