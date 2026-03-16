CREATE PROCEDURE [dbo].[MSG_PREPARE_FILENOTIFICATION] @aDeviceID int, @aUserID int, @aOperationID int = null /* KB4213 (KB2742) дял правильной фильтрации необходимых подписок */
AS
BEGIN
set nocount on
  
declare @CustomerID int
declare @mtid int
declare @depid int
declare @modelid int
declare @SN nvarchar(50)
declare @PN nvarchar(150)


declare @EventType int = 1 --производственный заказ по умолчанию для фильтра подписок в MSG_FILENOTIFICATIONS (поддержка стандартного варианта исполнеия процедуры до исправления) /* 10.08.2023 Efimov KB4213 (KB2742) добавлено для правильной фильтрации необходимых подписок */


/* KB4213 (KB2742) => */  
/* реализация дополнительной проверки если передали в процедуру необязательный параметр ID операции (используется в PR_NEXT_OPERATION4) */
if(@aOperationID is not null) --ТОЛЬКО ЕСЛИ ПЕРЕДАЛИ Operation ID то нужно проверить не из Сервисного ли заказа опрерация и если да то не RMA ли
begin
	--тип и номер заказа
	declare @aOrderType int;
	declare @aOrderNumber varchar(200);

	--вычисляем тип и номер заказа
	select 
		@aOrderType = ORD.ORDERTYPE, 
		@aOrderNumber = ORD.NN
	from PR_OPERATION OPER with (nolock)
		join PR_PRORDER ORD with (nolock) on OPER.ORDERID = ORD.ID
	where 
		OPER.ID = @aOperationID -- по данной операции
		and
		OPER.DEVICEID = @aDeviceID -- что операция по данному девайсу (Доп проверка всякий случай, чтобы не вызвали откуда-то с операцией не по своему девайсу)
			

	-- ТОЛЬКО если все таки операция принадлежит Service Order то выполняем дальнейшую проверку  
	-- ЕСЛИ НЕ СЕРВИСНЫЙ то ВСЕ ИДЕТ СВОИМ ЧЕРЕДОМ КАК И РАНЬШЕ
	if(@aOrderType = 1) 
	begin -- то проверяем на RMA
		if(@aOrderNumber like 'RMA%') -- если RMA
		begin
			set @EventType = 2 -- но меняем @EventType для фильтра подписок в MSG_FILENOTIFICATIONS (подписки об окончании ремонта)
		end
		else -- Service Order но не RMA то не обрабатываем добавление в MSG_FILENOTIFICATIONS_OUT (отправку)
		begin
			set nocount off
			return;  -- выход - не нужно обрабатывать сервисный не RMA (KB )
		end	
	end

end

--print 'EventType:'	
--print @EventType		
/* <= KB4213 (KB2742) */



select @CustomerID = isnull(C.CUSTOMERID, B.CUSTOMERID)
      ,@mtid = M.TYPEID
      ,@depid = B.DEPARTMENTID
      ,@modelid = A.MODELID
      ,@SN = A.SN
      ,@PN = M.CODE
from PR_DEVICE A with (nolock)
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
where A.ID = @aDeviceID

delete from MSG_FILENOTIFICATIONS_OUT 
where DEVICEID = @aDeviceID 
  and S_S = 1000178 /*wait NAV*/
  and CUSTOMERID <> @CustomerID


-- проверяем существует ли подписка у данного девайса
if exists (select A.ID 
             from MSG_FILENOTIFICATIONS A with (nolock) 
             left join MSG_FILENOTIFICATIONS_CONTACTS X with (nolock) on X.VNESHID = A.ID
             left join COM_CUST_CONTACTS C with (nolock) on C.ID = X.CONTACTID
            where A.MTID = @mtid
              and A.DEPID = @depid
              /*and A.CUSTOMERID = @CustomerID*/
              and C.CUSTOMERID = @CustomerID
              and (isnull(A.ALLMODELS,0) =1 or exists (select N.ID from MSG_FILENOTIFICATIONS_MODELS N with (nolock) where N.VNESHID = A.ID and N.MODELID = @modelid))
              and A.S_S = 1000176 /*approved*/
			  and A.EVENTTYPE = @EventType /* KB4213 (KB2742) для своего типа подписки */
              )
begin

   delete from MSG_FILENOTIFICATIONS_OUT where DEVICEID = @aDeviceID and S_S = 1000184 /*missed files*/
   
   /*KB1026 переформирование если файл изменился*/
   delete from MSG_FILENOTIFICATIONS_OUT where DEVICEID = @aDeviceID and S_S = 1000178/*wait NAV*/
      and dbo.MSG_FILENOTIFICATIONS_FILEWASCHANGED(MSG_FILENOTIFICATIONS_OUT.ID) = 1

   declare @ids table (ID int not null)

   insert into MSG_FILENOTIFICATIONS_OUT (GID,S_S,S_CR,S_CDT,SBSCID,DEVICEID,CRDATE,CUSTOMERID) output inserted.ID into @ids
   select newid(),1000178/*wait NAV*/,@aUserID,getdate(),M.ID,@aDeviceID,getdate(),@CustomerID
   from (
       select distinct A.ID 
       from MSG_FILENOTIFICATIONS A with (nolock) 
       left join MSG_FILENOTIFICATIONS_CONTACTS X with (nolock) on X.VNESHID = A.ID
       left join COM_CUST_CONTACTS C with (nolock) on C.ID = X.CONTACTID
       where A.MTID = @mtid
         and A.DEPID = @depid
         /*and A.CUSTOMERID = @CustomerID*/
         and C.CUSTOMERID = @CustomerID
         and not exists (select B.ID from MSG_FILENOTIFICATIONS_OUT B where B.SBSCID = A.ID and B.DEVICEID = @aDeviceID)
         and (isnull(A.ALLMODELS,0) =1 or exists (select N.ID from MSG_FILENOTIFICATIONS_MODELS N where N.VNESHID = A.ID and N.MODELID = @modelid))
         and A.S_S = 1000176 /*approved*/
		 and A.EVENTTYPE = @EventType /* KB4213 (KB2742) для своего типа подписки */
   ) M
     
     
   insert into MSG_FILENOTIFICATIONS_OUT_FILES (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB,PARAMID)
   select newid(),A.ID, F.FILENAME, F.FILEDATE, F.FILESIZE, F.FILEBLOB, D.PARAMID
   from @ids A 
   left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.ID
   left join MSG_FILENOTIFICATIONS C with (nolock) on C.ID = B.SBSCID
   left join MSG_FILENOTIFICATION_T D with (nolock) on D.VNESHID = C.ID
   cross apply dbo.PR_DEVICE_PARAM_FILES(B.DEVICEID, D.PARAMID) F
   where F.ID is not null     
     
   insert into MSG_FILENOTIFICATIONS_OUT_FILES (GID,VNESHID,FILENAME,FILEDATE,FILESIZE,FILEBLOB,PARAMID)
   select newid(),A.ID, F.FILENAME, F.FILEDATE, F.FILESIZE, F.FILEBLOB, D.PARAMID
   from @ids A 
       left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.ID
       left join MSG_FILENOTIFICATIONS C with (nolock) on C.ID = B.SBSCID
       left join MSG_FILENOTIFICATION_B D with (nolock) on D.VNESHID = C.ID
       left join PR_DEVICE_BOM DB on D.BOMID=DB.BOMID and B.DEVICEID=DB.DEVICEID
       cross apply dbo.PR_DEVICE_PARAM_FILES(DB.PARTID, D.PARAMID) F
   where F.ID is not null 
   
   /* если нет необходимых файлов - послать письмо о ошибке создателю подписки */
   declare @whereNofiles table (ID int)
   insert into @whereNofiles (ID)
   select ID from @ids where dbo.MSG_SUBSCRIPTION_FILES_EXISTS(ID) = 0
   
   if exists (select ID from @whereNofiles)
   begin
    
    
         declare @sname nvarchar(200)
         declare @subj nvarchar(1024) 
         declare @body nvarchar(max)
         /*declare @creator int*/
         declare @noFilesNames nvarchar(max)
         declare @copyCC nvarchar(1024) 
         declare @toAddr nvarchar(1024) 
          
          declare nxx cursor local read_only for 
          select C.NAME, /*C.S_CR,*/ C.ERRTO, dbo.MSG_SUBSCRIPTION_FILES_NOTEXISTS_NAMES(A.ID) , C.ERRCOPYTO
            from @whereNofiles A
         left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.ID
         left join MSG_FILENOTIFICATIONS C with (nolock) on C.ID = B.SBSCID
          where C.ERRTO is not null
        open nxx 
        WHILE 1=1
        BEGIN
          FETCH NEXT FROM nxx INTO @sname, /*@creator,*/ @toAddr, @noFilesNames, @copyCC;
          IF @@FETCH_STATUS<>0 BREAK;

          set @subj = 'PDB customer subscription "'+@sname+'" failed with item '+@SN+'.'
          set @body = 'Dear All,<br><br>Unable to find required files by item '+@SN+' ('+@PN+') required for customer subscription "'+@sname+'":<br><b>'    
          set @body = @body + isnull(@noFilesNames,'')
          set @body = @body + '</b><br><br>Please, do not answer this e-mail.<br>Production Database'    
          
          /*exec MSG_SEND_TOUSER @aUserID, @creator, @subj , @body*/
          /*exec MSG_SEND_TOUSER_WITHCOPY @aUserID,  @creator, @copyCC, @subj , @body*/
          exec MSG_SEND @aUserID, @toAddr, @copyCC, @subj , @body
           

        END
        close nxx;
        deallocate nxx;   
    
   end
   

end              
     
set nocount off
END