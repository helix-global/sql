
--DECLARE @UserID int =  53 --53--26052-- 53 --998 --36052
--DECLARE @VacationID int = 143626


CREATE function [dbo].[MOBILE_VACATION_INTERSECTIONS] (@UserID int, @VacationID int)
returns @res table (NAME varchar(200), DBEG DATETIME, DEND DATETIME, VACATIONTYPE int, 
					REMARK varchar(MAX), VACTIONTYPE varchar(50), SHORTDURATION varchar(50), SHORTSTART DATETIME, VACATIONTYPENAME varchar(50), APPROVED bit)
as 
begin

--Запрашиваемые даты
DECLARE @DBEG DateTime
DECLARE @DEND DateTime
--Сотрудник проверяемый
DECLARE @EMPLID int 
-- заполняем
select top 1 
	@EMPLID= EMPLID,
	@DBEG = DBEG,
	@DEND = ISNULL(DEND, DBEG)
from 
COM_VACATION where ID = @VacationID

--Пользователь проверяемый
DECLARE @VacationUserID int = dbo.COM_USER_BY_EMPL(@EMPLID)
--Департамент проверяемого пользователя
DECLARE @DEPID int = dbo.COM_USER_DEPARTMENT(@VacationUserID)

--список групп и ID сотрудников в который входит проверяемый сотрудник
DECLARE @IDSROWS table (IDSROWS varchar(max))

insert into @IDSROWS
select 
		IDSROWS
	from 
		dbo.com_empl_f_timeline(@UserID,@DBEG, @DEND)
	where 
		@VacationUserID in (select ID from dbo.COM_STR2TABLE_INT(IDSROWS))

--список всех сотружников в найденных группах
DECLARE @IDS varchar(max) = ''	
select @IDS = @IDS + IDSROWS from @IDSROWS    

--входит искомый сотрудник в хоть одну группу или нет?
DECLARE @INGOUP bit = (select COUNT(*) from @IDSROWS)

--выбираем все отсутсвия сотрудников в подчинении 
--если без группы то всех
--если с группой то из числа тех, кто входит в те же группы в которых состоит искомый сотрудник
-- и даты пересекаются
insert into @res
select 
	--E.DEPID, E.NAME,A.* 
	
	E.NAME,
	A.DBEG,
	isnull(A.DEND, A.DBEG) DEND,
	A.VACATIONTYPE,
	A.REMARK,
	dbo.COM_LANG_EN(T.NAME) PERIODTYPE,
	dbo.COM_LANG_EN(TT.NAME) SHORTDURATION,
	A.SHORTSTART,
	dbo.COM_LANG_EN(TTT.NAME) VACATIONTYPENAME,
	case when A.S_S = 1000141 then convert(bit,1) else convert(bit,0) end as APPROVED
from 
	COM_VACATION A with (nolock)
	left join COM_EMPLOYEE E with (nolock) on A.EMPLID = E.ID
	left join DEF_ENUMERATION_T T on T.CODE = A.PERIODTYPE and T.ENUMOID=1000120
	left join DEF_ENUMERATION_T TT on TT.CODE = A.SHORTDURATION and TT.ENUMOID=1000122
	left join DEF_ENUMERATION_T TTT on TTT.CODE = A.VACATIONTYPE and TTT.ENUMOID = 1000119
where 
	--начало запрашиваемого отсутсвия входит в данное отсутсвие
	((CONVERT(date,@DBEG) between CONVERT(date,DBEG) and CONVERT(date,isnull(DEND, DBEG)))
	or
	--или окончание запрашиваемого отсутсвия входит в данное отсутсвие
	(CONVERT(date,@DEND) between CONVERT(date,DBEG) and CONVERT(date,isnull(DEND, DBEG))))
	and
	-- и полдьзователь в той же группе что и искомый сотрудник
	(A.EMPLID in (select EMPLID from DEF_USERS where ID in (select DISTINCT ID from dbo.COM_STR2TABLE_INT(@IDS)))
	or
	-- или не состоит в группе, тогда все подчиненные сотрудники
	@INGOUP = 0
	)
	and
		E.DEPID = @DEPID
	and
	-- только те которые можно смотреть
	dbo.COM_VACATION_ACCESS3(A.S_CR,A.S_S,A.EMPLID,@UserID,11,getdate())=1
	-- и только определенных типов
	and A.S_S not in (1000142 /* Rejected */, 1000147 /* Canceled */)
	--исключая свои запросы
	and A.EMPLID <> @EMPLID
	return

end