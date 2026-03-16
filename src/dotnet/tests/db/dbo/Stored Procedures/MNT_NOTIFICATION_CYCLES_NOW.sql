

/* KB2654: "Send immediately" когда циклы до обслуживания закончились*/

/* Проверяем оборудование "By Equipment Work Cycles"на то что циклы использования закончились и наступает план обслуживания.
Текущее информирование (MNT_NOTIFICATION_PART2) приходит (запускается раз в сутки из MNT_NOTIFICATION_FUTURE) на след день 
и для оборудования у которого план обслуживания по "циклам испольования" нуждается 
в информировании "как только циклы закончились" и создана опреация обслуживания. */

/* RUN FROM [PR_CHECK_EQ_WORKCYCLES]*/

CREATE PROCEDURE [dbo].[MNT_NOTIFICATION_CYCLES_NOW] @OperationID int
AS
BEGIN

set nocount on

/***** TEST DATA *****/
--declare @OperationID int = 54092201
/***** TEST DATA *****/


/* Текущий пользователь */
declare @UserID int = [dbo].[DEF_USERID]()

/* оборудование учасвтсвующее в операции */
declare @eq table (ID int not null)

insert into @eq (ID)
select distinct G.EQID 
from PR_OPERATION_PARAMS G with (nolock)
where G.OPERID = @OperationID
  and G.EQID is not null


/* выбираем только то которое в плане обслуживания с "By Equipment Work Cycles" и с нотифкацией "Quantity Work Cycles" и уже использовано циклов больше указанного в плане */
declare @msgs table (EMPLID int not null, MNTPLANID int, EQID int, CYCLESLEFT int, WORKCYCLES int, MSGROW nvarchar(max))
insert into @msgs
 select 
		A.EMPLID, 
		P.ID MNTPLANID,
		E.EQID,
		P.WORKCYCLES - E.WORKCYCLES as CYCLESLEFT
		, E.WORKCYCLES
		, null
 from
	MNT_PLAN_NOTYRCV A with (nolock)
    left join MNT_PLAN P with (nolock) on P.ID = A.VNESHID
	left join MNT_PLAN_EQ E on E.VNESHID = P.ID
 where E.EQID in (select ID from @eq) 
	and P.SPERIOD = 100000		/* By Equipment Work Cycles */
    and P.S_S = 1
    and P.CRMODE in (3,4)		/*by eq*/
	and P.NOTIFICATIONP = 100	/*Quantity Work Cycles*/
	and P.NOTIFICATIONEXP = 2000 /* Send immediately */
	and E.WORKCYCLES >= P.WORKCYCLES
	and ISNULL(P.WEEKLY_ONLY,0)=0

	
	/* формируем строчки сообщения */
	update @msgs set MSGROW = dbo.MNT_NOTIFICATION_CYCLES_LEFT_HTMLROW_EXP(MNTPLANID, @OperationID, EQID, WORKCYCLES)


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
    set @oneMessage = 'Dear All,<br><br>The following equipment has reached its maintenance cycle and must be serviced (based on service plans and equipment cycles):<br><br>'
    
    set @oneMessage = @oneMessage + '<font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
    set @oneMessage = @oneMessage + '<tr><th>Maintenance Plan</th><th>Operation Cycles</th><th>Equipment Model</th><th>Equipment SN</th><th>Equipment TAG Nr.</th><th>Working Place</th><th>Department</th><th>Responsible Person</th><th>Equipment Type</th><th>Remark</th></tr>'
    
    select @oneTable = @oneTable + A.MSGROW
      from @msgs A where A.EMPLID = @oneEmplID order by A.CYCLESLEFT
    
    set @oneMessage = @oneMessage + @oneTable + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'
    
    exec MSG_SEND_TOEMPLOYEE @UserID, @oneEmplID, 'Maintenance Plan Notification', @oneMessage
    --select @UserID, @oneEmplID, 'Maintenance Plan Notification', @oneMessage
    
  END
  close nxx;
  deallocate nxx;   

END