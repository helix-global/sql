
CREATE PROCEDURE [dbo].[MSG_ABSENCE_REPORT_TIMELINE] @aUserID int
AS
BEGIN


/* KB2556 */
/* Отправка таймлайн отчета по отсутствиям по списку рассылки */
/* Начальники департаментов сами устанавливают кто будет получать отчет в настройках списка рассылки */
/* Через меню Administrator > PDB Settings > Notification DElivery E-Mails*/

/*KB2715 Edit Fix 26.10.2021 Efimov*/
/* Если есть подчиненные отделы то табдлицы по ним тоже вставляются в тело письма*/

/* KB4739 update display other type absence 15.08.2024 efimov */


/* TEST DATA */
--declare @aUSERID int = 26052
/* TEST DATA */

set nocount on

declare @DELIVERYTYPE int = 2310 -- список рассылки
declare @SUBJ varchar(250) = 'Department Absence TimeLine Report'
declare @HTML varchar(MAX)
declare @DELIVERYDEPID int

declare @REPORTTIME time = '06:00' -- Report create and send time

declare @nowDateTime datetime = getdate()
--declare @nowDateTime datetime = '20210702 06:01:00'
declare @nowTIME time =  cast(@nowDateTime as time)
declare @nowDATE date =  cast(@nowDateTime as date) 



-- ############## ПРОВЕРКА НА РАБОЧИЕ ДНИ НЕДЕЛИ #########################################

if ([dbo].[COM_IS_WORKDAY] (@nowDateTime,1) = 0)
begin
   print 'exit (nobody need report at weekends)'
   set nocount off
   return
end


-- ################# ПРОВЕРКА НА УЖЕ ОТПРАВЛЕННЫЙ ОТЧЕТ ###########################################

 if exists (select G.DD from MSG_LAST_DELIVERY_DATES G where G.DELIVERYTYPE = @DELIVERYTYPE and G.DEPID = -1 and G.DD = cast(@nowDATE as date))
 begin
   print 'exit (today already done)'
   set nocount off
   return
 end


-- ################# ПРОВЕРКА НАСТУПИЛО ЛИ ВРЕМЯ ДЛЯ ОТПРАВКИ НОВОГО ОТЧЕТ ########################################### 

 print 'report send time: ' + CAST(@REPORTTIME as varchar(5))
 print 'current time    : ' + cast(@nowTime as varchar(5))
 
 if  @nowDateTime <= (CAST(@nowDATE as datetime) + CAST(@REPORTTIME as datetime)) 
 begin
	print 'exit (it is not time to send)'
	set nocount off
    return
 end
	
print CHAR(13) + 'TIME TO SEND REPORT !!!' + CHAR(13)

DECLARE my_cur CURSOR FOR 
	select DEPID from MSG_DELIVERYLIST with (nolock) where DELIVERYTYPE = @DELIVERYTYPE
	--открываем курсор
	OPEN my_cur
	--считываем данные первого отдела из списка рассылки
	FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  --прока есть периоды в списке дней Vacations работника
	  WHILE @@FETCH_STATUS = 0
	  BEGIN
		  set @HTML = dbo.COM_DEP_VACATIONS_HTML_TABLE4(GETDATE(), 8, @DELIVERYDEPID) --KB4739 (was COM_DEP_VACATIONS_HTML_TABLE2)
		  print '###################'
		  select @DELIVERYDEPID, @DELIVERYTYPE,(select top 1 [NAME] from  dbo.COM_DEPARTMENTS where ID=@DELIVERYDEPID), @HTML

		  exec MSG_SEND_TODELIVERYGROUP @aUSERID, @DELIVERYTYPE, @DELIVERYDEPID, @SUBJ, @HTML
		  print 'Report SEND to DepID ' + convert(varchar,@DELIVERYDEPID)

	      FETCH NEXT FROM my_cur INTO @DELIVERYDEPID
	  END
	 CLOSE my_cur
DEALLOCATE my_cur


	print '###################'
	insert into MSG_LAST_DELIVERY_DATES (DELIVERYTYPE,DEPID,DD) values (@DELIVERYTYPE,-1, @nowDate)
	print 'Report date is inserted in [MSG_LAST_DELIVERY_DATES].'
	print 'Report SEND to Group.'


set nocount off

end