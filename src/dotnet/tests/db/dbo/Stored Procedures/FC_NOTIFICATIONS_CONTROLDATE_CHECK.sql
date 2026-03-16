CREATE PROC FC_NOTIFICATIONS_CONTROLDATE_CHECK (@UserID int)
as
begin


/*KB2887 - IPM - New notifications about Corrective Actions*/

/*TEST*/
--DECLARE @UserID int = 26052
/*TEST*/

DECLARE @now datetime = getdate() --'20220308 18:00:00'
DECLARE @weekday int = (SELECT dbo.COM_DAY_OF_WEEK(@now))
DECLARE @todayDate date = @now
DECLARE @todayTime time  = @now



/*
notify type
-----------
0 - before Contro lDate
1 - after  Control Date

notifyrate 0 (before Contro lDate)
----------------------------------
10 - every work day at 8:00
20 - every Monday, Wensday, Friday  (1,3,5) at 8:00
30 - Weekly in Monday (1) at 8:00

notifyrate 1 (after Contro lDate)
----------------------------------
10 - every work day at 8:00
20 - every Monday, Wensday, Friday  (1,3,5) at 8:00
30 - Weekly in Monday (1) at 8:00

*/

DECLARE @reporttime time = '8:00'
DECLARE @IDs varchar(max) = ''


/************************* BEFORE *************************/

-- Проверяем не наступило ли время отправки уведомилений 0-10 (before daily)
if(@weekday in (1,2,3,4,5)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 0 and NOTIFRATE = 10 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_BEFORE_RATE = 10	/* rate - every work day at 8:00*/
			and 
			DATEDIFF(day, @todayDate, CORRACTION.PDATE) between 0 and CORRACTION.NOTIFICATION_BEFORE_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 1, @IDs, @UserID

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(0, 10, @todayDate) 
	end
end



-- Проверяем не наступило ли время отправки уведомилений 0-20 (before 3 day in Weenk)
if(@weekday in (1,3,5)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 0 and NOTIFRATE = 20 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_BEFORE_RATE = 20	/* rate - every mon wen fr  day at 8:00*/
			and 
			DATEDIFF(day, @todayDate, CORRACTION.PDATE) between 0 and CORRACTION.NOTIFICATION_BEFORE_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 1, @IDs, @UserID

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(0, 20, @todayDate) 
	end
end

-- Проверяем не наступило ли время отправки уведомилений 0-30 (before Weekly in monday)
if(@weekday in (1)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 0 and NOTIFRATE = 30 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_BEFORE_RATE = 30	/* rate - every monday at 8:00*/
			and 
			DATEDIFF(day, @todayDate, CORRACTION.PDATE) between 0 and CORRACTION.NOTIFICATION_BEFORE_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 1, @IDs, @UserID
		

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(0, 30, @todayDate) 
	end
end


/************************* AFTER *************************/
-- Проверяем не наступило ли время отправки уведомилений 1-10 (after daily)
if(@weekday in (1,2,3,4,5)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 1 and NOTIFRATE = 10 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_AFTER_RATE = 10	/* rate - every work day at 8:00*/
			and 
			DATEDIFF(day,  CORRACTION.PDATE, @todayDate) between 1 and CORRACTION.NOTIFICATION_AFTER_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 0, @IDs, @UserID

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(1, 10, @todayDate) 
	end
end


-- Проверяем не наступило ли время отправки уведомилений 0-20 (after 3 day in Weenk)
if(@weekday in (1,3,5)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 1 and NOTIFRATE = 20 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_AFTER_RATE = 20	/* rate - every mon wen fr day at 8:00*/
			and 
			DATEDIFF(day, CORRACTION.PDATE, @todayDate) between 1 and CORRACTION.NOTIFICATION_AFTER_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 0, @IDs, @UserID

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(1, 20, @todayDate) 
	end
end

-- Проверяем не наступило ли время отправки уведомилений 0-30 (after Weekly in monday)
if(@weekday in (1)  and (@todayTime > @reporttime)) -- понедельник после 8
begin 
	--проверяем не отправляли ли еще сегодня
	if (NOT EXISTS(select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE] where NOTIFTYPE = 1 and NOTIFRATE = 30 and NOTIFDD = @todayDate))
	begin 
		set @IDs = ''
		--Выбираем удовлетворяющие условию ID записей из Corrective Actions
		select 
			@IDs = @IDs + ',' + convert(varchar,ID)
		from 
			FC_CORRACTIONS CORRACTION 
		where 
			CORRACTION.S_S = 1000154					/* InProgress */
			and
			CORRACTION.NOTIFICATION_AFTER_RATE = 30	/* rate - every monday at 8:00*/
			and 
			DATEDIFF(day, CORRACTION.PDATE, @todayDate) between 1 and CORRACTION.NOTIFICATION_AFTER_CD  /* betwiin 0 and X days before ControlDate*/

		--Запускаем отправку писем по найденным Corrective Actions
		if(len(@IDs) > 0)
			exec FC_NOTIFICATIONS_CONTROLDATE_SEND 0, @IDs, @UserID

		-- проставляем в таблице , что сегодня отправка была по данному Notification Rate
		insert into [dbo].[FC_NOTIFICATIONS_CONTROLDATE] values(1, 30, @todayDate) 
	end
end


-- select * from [dbo].[FC_NOTIFICATIONS_CONTROLDATE]

end