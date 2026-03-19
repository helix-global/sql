CREATE TABLE [dbo].[PR_OPERATION_TIME] (
    [ID]          INT              IDENTITY (1, 1) NOT NULL,
    [GID]         UNIQUEIDENTIFIER NULL,
    [S_CR]        INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [S_MR]        INT              NULL,
    [S_MDT]       DATETIME         NULL,
    [ARC]         INT              NULL,
    [OPERID]      INT              NOT NULL,
    [USERID]      INT              NOT NULL,
    [DBEG]        DATETIME         NOT NULL,
    [DEND]        DATETIME         NULL,
    [EMPID]       INT              NULL,
    [ELAPSED]     INT              NULL,
    [ELAPSEDCORR] INT              NULL,
    [CORRTYPE]    INT              NULL,
    [IDLE_TIME]   INT              NULL,
    [ELAPSED_D]   DECIMAL (12, 2)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PR_OPERATION_TIME_OPERID] FOREIGN KEY ([OPERID]) REFERENCES [dbo].[PR_OPERATION] ([ID]) ON DELETE CASCADE,
    CONSTRAINT [FK_PR_OPERATION_TIME_USERID] FOREIGN KEY ([USERID]) REFERENCES [dbo].[DEF_USERS] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME_OPERID_DBEG_DEND]
    ON [dbo].[PR_OPERATION_TIME]([OPERID] ASC)
    INCLUDE([DBEG], [DEND]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME_DBEG_ID_OPERID_DEND_EMPID]
    ON [dbo].[PR_OPERATION_TIME]([DBEG] ASC)
    INCLUDE([ID], [OPERID], [DEND], [EMPID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME4]
    ON [dbo].[PR_OPERATION_TIME]([EMPID] ASC, [DBEG] ASC)
    INCLUDE([DEND], [OPERID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME3]
    ON [dbo].[PR_OPERATION_TIME]([USERID] ASC, [DBEG] ASC, [DEND] ASC)
    INCLUDE([OPERID]);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME2]
    ON [dbo].[PR_OPERATION_TIME]([DEND] ASC, [EMPID] ASC, [DBEG] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME1]
    ON [dbo].[PR_OPERATION_TIME]([EMPID] ASC, [DBEG] ASC, [DEND] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_PR_OPERATION_TIME]
    ON [dbo].[PR_OPERATION_TIME]([OPERID] ASC, [USERID] ASC)
    INCLUDE([DEND]) WITH (FILLFACTOR = 90);


GO
CREATE trigger [dbo].[TR_PR_OPERATION_TIME] on [dbo].[PR_OPERATION_TIME]
FOR insert, update, delete
as 
  
  if TRIGGER_NESTLEVEL() > 1 return
  set nocount on  
  
  declare @UserID int /*02.07.14 NDA супервизору разрешено нарушать графики других*/
  set @UserID = dbo.DEF_USERID()
  
  IF dbo.DEF_USERINGROUP5(@UserID,'SPV','OGH3','AGENT',null,null) = 0 /*KB2170*/
  BEGIN
  
	  /* 10 минут BEGIN */  
	  DECLARE @EMP_ID INT
			 ,@USER_ID INT 
			 ,@DT_BEG DATETIME
			 ,@DT_END DATETIME
	  DECLARE INS_CUR CURSOR local read_only FOR SELECT EMPID,USERID,DBEG,DEND FROM INSERTED
	  OPEN INS_CUR
	  WHILE 1=1
	  BEGIN
		  FETCH NEXT FROM INS_CUR INTO @EMP_ID,@USER_ID, @DT_BEG, @DT_END
		  IF @@FETCH_STATUS<>0 BREAK;
		  -- если операция ОТКРЫВАЕТСЯ
		  
		  if @DT_END is null
			if dbo.COM_IS_WORKTIME2(@DT_BEG,@EMP_ID) <> 1 
			   EXEC COM_CHECK_AND_ADD_WORKTIME2 @EMP_ID, @USER_ID, @DT_BEG, 1
			   
		  -- если операция ЗАКРЫВАЕТСЯ
		  
		  if @DT_END is not null
			if dbo.COM_IS_WORKTIME2(@DT_END,@EMP_ID) <> 1 
			   EXEC COM_CHECK_AND_ADD_WORKTIME2 @EMP_ID, @USER_ID, @DT_END, 2
			   
	  END  
	  CLOSE INS_CUR
	  DEALLOCATE INS_CUR
	  /* 10 минут END */  
  	  
	  

  	if exists (select * from inserted A where dbo.COM_IS_WORKTIME2(A.DBEG,A.EMPID) <> 1 and A.DEND is null)
	  raiserror(50001/*'Activity out of working hours. Please add overtime hours.[L=com_out_of_work_time'*/,16,1)

	if exists (select * from inserted A where A.DEND is not null and dbo.COM_IS_WORKTIME2(A.DEND,A.EMPID) <> 1) 
	  raiserror(50001/*'Activity out of working hours. Please add overtime hours.[L=com_out_of_work_time'*/,16,1)

  END

    
  update PR_OPERATION_TIME set ELAPSED_D = dbo.PR_WORKTIME5(ID,DEND) /*dbo.PR_WORKTIME4(ID,DEND) NDA 22.08.18 */
  where ID in (select ID from inserted) and DEND is not null

  update PR_OPERATION_TIME set ELAPSED = round(ELAPSED_D,0)
  where ID in (select ID from inserted) and DEND is not null

/*
  update PR_OPERATION_TIME set IDLE_TIME = dbo.PR_GET_USER_IDLE_TIME_BEFORE_OPERATION(ID,DBEG,DEND,EMPID,cast(cast(DBEG as date) as datetime))
  where ID in (select ID from inserted)
    and DEND is null
*/

update PR_OPERATION_TIME 
set IDLE_TIME = dbo.PR_GET_USER_IDLE_TIME_BEFORE_OPERATION(ID,DBEG,DEND,EMPID,cast(cast(DBEG as date) as datetime))
from PR_OPERATION_TIME WITH (INDEX(PK__PR_OPERA__3214EC273AA1AEB8)/*Incident# 230732 */)
  where ID in (select ID from inserted)
    and DEND is null
    

  /*TODO нужно пересчитать по тем-же пользователям операции в пересекающихся периодах*/
  
  
  /*пересчет накопленной статистики по изделиям*/
  declare @devID int, @ordID int
  DECLARE recalc CURSOR local read_only FOR
  select distinct B.DEVICEID, B.ORDERID
    from PR_OPERATION B with (nolock)
    left join PR_DEVICE C with (nolock) on C.ID = B.DEVICEID
    where B.ID in (select OPERID 
                     from inserted where DEND is not null
                    union
                    select OPERID 
                     from deleted where DEND is not null)
      and C.ORDERID = B.ORDERID /*пока считаем только по произв.заказам*/
      and C.COMPLETED_DT is not null /*пока только для правок после завершения изделия*/
  OPEN recalc
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM recalc INTO @devID, @ordID
      IF @@FETCH_STATUS<>0 BREAK;
      exec PR_DEVICE_UPD_STAT @devID, @ordID
  END  
  CLOSE recalc
  DEALLOCATE recalc
  
  
  /*пересчет статистики по операции*/
  declare @opID int
  declare @mindend datetime
  DECLARE recalc2 CURSOR local read_only FOR
  select distinct OPERID 
     from (select OPERID 
             from inserted where DEND is not null
            union select OPERID 
             from deleted where DEND is not null) M
  OPEN recalc2
  WHILE 1=1
  BEGIN
      FETCH NEXT FROM recalc2 INTO @opID
      IF @@FETCH_STATUS<>0 BREAK;
      
      select @mindend = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID = @opID      
      
      update PR_OPERATION set 
         SUM_OPERATION_STAT_1 = (select SUM(coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED)) from PR_OPERATION_TIME A with (nolock) where A.OPERID = PR_OPERATION.ID)
        ,SUM_OPERATION_STAT_4 = datediff(mi,PR_OPERATION.S_CDT,@mindend)
      where PR_OPERATION.ID = @opID
      
  END  
  CLOSE recalc2
  DEALLOCATE recalc2
  
  set nocount off