CREATE PROCEDURE [dbo].[FC_CREATE_EXTERNAL_FAR]  @aParentFarID int,@DepID int, @UserID int, @mode int
AS
BEGIN
set nocount on

if exists (select A.ID from FC_REPORT A with (nolock) where A.EXTPARENTID = @aParentFarID)
begin

   /*KB1447 ->*/
   declare @hisState int
   select @hisState = A.S_S from FC_REPORT A with (nolock) where A.EXTPARENTID = @aParentFarID
   if @hisState = 2130021 /*generated*/
   begin
      exec FC_REFILL_EXTERNAL_FAR @aParentFarID, @UserID, 0
      exec FC_UPDATE_EXTERNAL_FAR @aParentFarID, @UserID, 0
      print 'External FAR updated'
      set nocount off
      return
   end
   /*KB1447 <-*/


   raiserror('#EExternal FAR already requested.',16,0)
   set nocount off
   return
end  

declare @transid int
declare @parentState int
select @transid = C.ID
   ,@parentState = A.S_S
from FC_REPORT A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
left join FC_EXT_TRANSLATION C with (nolock) on C.MTID = B.TYPEID and C.ENDDEPID = @DepID
where A.ID = @aParentFarID
  
if @transid is null
begin
   raiserror('#EUnable to create external FAR by this model type and department.',16,0)
   set nocount off
   return
end  
  

declare @now datetime = getdate()
declare @newid int

insert into FC_REPORT (EXTPARENTID
                    ,EXTREQDEPID
                    ,GID
                    ,S_S
                    ,S_CR
                    ,S_CDT
                    ,PARENTID
                    ,FAILUREDATE
                    ,WARRANTY
                    ,RMA_TYPE
                    ,RMA
                    ,OTHERRMA
                    ,FROMDEPID
                    ,FROMCUSTOMERID
                    ,DEVICEID
                    ,QUANTITY
                    ,OPERTIME
                    ,CUSTREF
                    ,FAILUREDESCRIPTION
                    ,REQUESTEDACTIONS
                    ,MODELID
                    ,SN
                    ,INT_EXT
                    ,USER3DT
                    ,DATE_PRODUCT3
                    ,CORR_ACTION_DATE
                    ,CORRECTIVE_ACTION
                    ,ACTIONPOINTS
                    ,OFFICEID
                    ,BATCHN
                    ,REMARK
                    ,INTERNALREMARK
                    ,USER1DT)
select A.ID
        ,@DepID
        ,newid()
        ,case when A.S_S=1000104/*approved*/ then 2130021 /*generated*/ else 2130020/*requested*/ end
        ,@UserID
        ,@now
        ,A.PARENTID
        ,A.FAILUREDATE
        ,A.WARRANTY     
        ,A.RMA_TYPE
        ,A.RMA
        ,A.OTHERRMA
        ,A.FROMDEPID
        ,A.FROMCUSTOMERID
        ,A.DEVICEID
        ,A.QUANTITY
        ,A.OPERTIME
        ,A.CUSTREF
        ,A.FAILUREDESCRIPTION
        ,A.REQUESTEDACTIONS
        ,A.MODELID
        ,A.SN
        ,A.INT_EXT
        ,USER3DT
        ,DATE_PRODUCT3
        ,CORR_ACTION_DATE
        ,CORRECTIVE_ACTION
        ,ACTIONPOINTS
        ,OFFICEID
        ,BATCHN
        ,REMARK
        ,INTERNALREMARK
        ,USER1DT
from FC_REPORT A with (nolock)
where A.ID = @aParentFarID          
      
set @newid = SCOPE_IDENTITY()

exec FC_GEN_NEXT_FRNUM @newid, 0

    declare @fcodeParentId int, @fcodeNewId int

    DECLARE cur_FC_CREATE_EXTERNAL_FAR CURSOR FOR
    select A.ID
        from FC_REPORT_CODES A with (nolock)
        where A.VNESHID = @aParentFarID 
                    
    OPEN cur_FC_CREATE_EXTERNAL_FAR

    FETCH NEXT FROM cur_FC_CREATE_EXTERNAL_FAR INTO @fcodeParentId

    WHILE @@FETCH_STATUS=0
    BEGIN
        insert into FC_REPORT_CODES (GID,S_CR,S_CDT,VNESHID,REPCODEID)
            select newid(),A.S_CR,A.S_CDT,@newid,A.REPCODEID
                from FC_REPORT_CODES A with (nolock)
                where A.ID = @fcodeParentId
        
        set @fcodeNewId = SCOPE_IDENTITY()

        insert into FC_REPORT_ANALYSIS_CODES (GID,S_CR,S_CDT,VNESHID,ANALYSISCODEID,OPTS,FCODE,INITI)
            select newid(),A.S_CR,A.S_CDT,@newid,T.EXTCODEID,OPTS,@fcodeNewId,INITI
            from FC_REPORT_ANALYSIS_CODES A with (nolock)
                join (select CODEID, EXTCODEID from FC_EXT_TRANSLATION_T where VNESHID=@transid) T on A.ANALYSISCODEID=T.CODEID
            where A.FCODE=@fcodeParentId
    
        FETCH NEXT FROM cur_FC_CREATE_EXTERNAL_FAR INTO @fcodeParentId
    END

    CLOSE cur_FC_CREATE_EXTERNAL_FAR
    DEALLOCATE cur_FC_CREATE_EXTERNAL_FAR
    
    insert into FC_REPORT_FILES ( FILEBLOB
                                , FILEDATE
                                , FILEDESC
                                , FILENAME
                                , FILEPREVIEW
                                , FILESIZE
                                , GID
                                , S_CDT
                                , S_CR
                                , VNESHID) 
        select FILEBLOB
                , FILEDATE
                , FILEDESC
                , FILENAME
                , FILEPREVIEW
                , FILESIZE
                , newid()
                , getdate()
                , @UserID
                , @newid
            from FC_REPORT_FILES
            where VNESHID=@aParentFarID


if @parentState = 1000104 /*approved*/  /* создание eFAR на уже утвержденный FAR*/
begin
  exec FC_UPDATE_EXTERNAL_FAR @aParentFarID, @UserID, 0
end

set nocount off

END