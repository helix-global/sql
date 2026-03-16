CREATE FUNCTION [dbo].[PR_FOC_FIBER_USAGE_RINGS]
(
	@FiberSN nvarchar(25),
	@deviceId int
)
RETURNS @ret TABLE (RN nvarchar(100), PF nvarchar(4), OPERID int, PVALUE nvarchar(100))
BEGIN
	/*
	Функция выводит информацию по кольцам волокна, установленным в блоке для отчета FOC Fiber Usage
	RN - номер кольца
	PF - результат тестирования
	OPERID - операция установки
	PVALUE - код отказа
	*/

	declare @partId int

	select @partId = ID
		from PR_DEVICE D
		where D.SN=@FiberSN

	declare @tabBomPar table (BOMID int, PARAMID int, R int)

	-- параметры и бомы для колец
	insert into @tabBomPar (BOMID, PARAMID, R)
	select B.ID, P.ID, case when B.NAME='Active Fiber Ring 1' then 1 else 2 end
		from PR_MODELTYPE_BOM B
			join PR_MODELTYPE_PARAMS_GR G on B.MTID=G.TYPEID
			join PR_MODELTYPE_PARAMS P on G.ID=P.PGROUP
		where (B.NAME='Active Fiber Ring 1' and P.NAME='Active Fiber Ring 1, Nr.')
			or
				(B.NAME='Active Fiber Ring 2' and P.NAME='Active Fiber Ring 2, Nr.')


	declare @tRes table (
						DEVICEID int
						, RN nvarchar(100) 
						, PF nvarchar(4)
						, OPERID int -- операция установки
						, PTOPERID int -- операция тестирования
						) 
	declare @INOPERID int, @UNOPERID int, @PARAMID int

	declare cur_main cursor for
	select O.ID as INOPERID, 
			U.OPERID as UNOPERID,  
			BP.PARAMID
		from PR_OPERATION_INSTALL I
			join PR_OPERATION O on I.OPERID=O.ID
			join @tabBomPar BP on I.BOMID=BP.BOMID
			left join PR_OPERATION_UNINSTALL U on I.ID=U.INSTALLROWID
		where O.DEVICEID=@deviceId and I.PARTID=@partId
		order by I.S_CDT
					
	open cur_main

	fetch next from cur_main into @INOPERID, @UNOPERID, @PARAMID

	while @@fetch_status=0
	begin
	
		if @UNOPERID is not null --если деинсталлировано, то FAIL и берется первая из следующих операция тестирования
		begin

			insert into @tRes (DEVICEID, RN, OPERID, PF, PTOPERID)
			select @deviceId, isnull(cast(PVALUE as nvarchar(100)),''), O.ID, 'FAIL',
					case when O.S_S=1000038 then null else (select min(O.ID)
						from PR_OPERATION O
							join PR_OPERATIONS T on O.OPERTYPEID=T.ID
						where T.NAME like '%PT%' and O.ID>P.OPERID and O.DEVICEID=@deviceId) end
				from PR_OPERATION_PARAMS P
					join PR_OPERATION O on P.OPERID=O.ID
					join @tabBomPar BP on P.PARAMID=BP.PARAMID
				where O.DEVICEID=@deviceId and P.PARAMID=@PARAMID
					and P.OPERID>=@INOPERID and P.OPERID<=@UNOPERID
				order by O.ID

		end
		else -- если не деинсталлировано, то PASS
		begin

			insert into @tRes (DEVICEID, RN, OPERID, PF)
			select @deviceId, isnull(cast(PVALUE as nvarchar(100)),''), P.OPERID, 'PASS'
				from PR_OPERATION_PARAMS P
					join PR_OPERATION O on P.OPERID=O.ID
					join @tabBomPar BP on P.PARAMID=BP.PARAMID
				where O.DEVICEID=@deviceId and P.PARAMID=@PARAMID
					and P.OPERID>=@INOPERID
				order by O.ID

		end
	
		 fetch next from cur_main into @INOPERID, @UNOPERID, @PARAMID
	end

	close cur_main
	deallocate cur_main

	declare @RN nvarchar(100), @operId int 

	declare @RN_tmp nvarchar(100) = null, @operId_tmp int = null

	--удаление лишних записей (если операция тестирования выявила неполадки, но кольцо не менялось, то в таблице есть задвоение)
	declare cur_sub cursor for
	select RN, OPERID
		from @tRes
					
	open cur_sub

	fetch next from cur_sub into @RN, @operId

	while @@fetch_status=0
	begin
	
		if @operId_tmp is null
		begin
			set @operId_tmp = @operId
			set @RN_tmp = @RN
		end
		else
		begin
		
			if @RN_tmp=@RN
				delete from @tRes where OPERID=@operId
			else
			begin
				update @tRes set PF='FAIL' where OPERID=@operId_tmp
				set @operId_tmp = @operId
			end

			set @operId_tmp = @operId
			set @RN_tmp = @RN
		end
	
	
		 fetch next from cur_sub into @RN, @operId
	end

	close cur_sub
	deallocate cur_sub

	insert into @ret
	select RN, PF, T.OPERID, P.PVALUE
		from @tRes T
			left join (select P.OPERID, cast(P.PVALUE as nvarchar(100)) as PVALUE
						from PR_OPERATION_PARAMS P 
							join PR_OPERATION O on P.OPERID=O.ID
							left join PR_MODELTYPE_PARAMS MP on P.PARAMID=MP.ID
						where O.DEVICEID=@deviceId and MP.NAME='PreTest_Failure Code') P on T.PTOPERID=P.OPERID
	
	RETURN 
END