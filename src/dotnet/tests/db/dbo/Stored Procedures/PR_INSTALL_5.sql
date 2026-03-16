CREATE procedure [dbo].[PR_INSTALL_5] @OperID int, @CloseWithErr int, @UserID int
as 
set nocount on

declare @RevID int
declare @OrdID int
declare @DevID int
declare @DevDepID int

select @RevID = B.REVID
     , @OrdID = A.ORDERID
	 , @DevID = A.DEVICEID
	 /*, @DevDepID = T.DEPARTMENTID*/
	 , @DevDepID = M.DEPID
from PR_OPERATION A with (nolock)
left join PR_DEVICE B on B.ID = A.DEVICEID
left join PR_MODELS M on M.ID = B.MODELID
left join PR_MODELTYPE T on T.ID = M.TYPEID
where A.ID = @OperID

/* 1 UNINSTALL */
declare @UnStat int
declare @UnDevID int
declare crUN cursor local read_only for 
	select A.UNITEMSTAT,B.PARTID
	from PR_OPERATION_UNINSTALL A
	left join PR_OPERATION_INSTALL B on B.ID = A.INSTALLROWID
	where A.OPERID = @OperID
open crUN;
WHILE 1=1
BEGIN
   FETCH NEXT FROM crUN INTO @UnStat,@UnDevID
   IF @@FETCH_STATUS<>0 BREAK;
   
   update PR_DEVICE set S_S = case @UnStat when 2 /* Unsuitable */ then 1000081 /* Uninstalled */ else 1000080 /*serv.req*/end
   where ID = @UnDevID
     and S_S in (1000077,1000080,1000081) /*installed, serv.req.*/
     and dbo.PR_DEVICE_ACCOUNTING(ID) = 0										
   
END
close crUN;
deallocate crUN;

  
/* 2 INSTALL поиск,проверка,генерация SN */

/*TODO найти модель по коду если он передан */

/*попытка заполнить пустую модель, если вариант только один*/
update PR_OPERATION_INSTALL 
/*set PARTMODELID = (select A.PARTMODELID from dbo.PR_DEVICE_BOM_MODELS(@DevID) A where A.BOMID = PR_OPERATION_INSTALL.BOMID and A.BOMIDMODELSCOUNT = 1 )*/
set PARTMODELID = (select top 1 A.PARTMODELID from dbo.PR_DEVICE_BOM_1_MODELS(@DevID,PR_OPERATION_INSTALL.BOMID) A where A.BOMIDMODELSCOUNT = 1 )		
where OPERID = @OperID
  and PARTMODELID is null

/*TODO найти прибор и модель если есть только один прибор подходящей модели*/
	
declare @sn nvarchar(200)
declare @modid int
declare @instid int
declare @bomid int
declare @partid int 

declare crSN cursor local read_only for 
	select A.SN,A.PARTMODELID,A.ID,A.BOMID
	from PR_OPERATION_INSTALL A
	where A.OPERID = @OperID
open crSN;
WHILE 1=1
BEGIN
   FETCH NEXT FROM crSN INTO @sn,@modid,@instid,@bomid
   IF @@FETCH_STATUS<>0 BREAK;
   
   exec PR_INSTALL_5ROW @instid, @sn, @modid,@bomid, @CloseWithErr, @DevID, @OrdID, @DevDepID, @UserID
   
END
close crSN;
deallocate crSN;

exec PU_CHECK_BATCH_NUMBERS @OperID

exec PR_UPDATE_EXT_PARAMS @OperID , @CloseWithErr , @UserID 

set nocount off