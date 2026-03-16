create PROCEDURE [dbo].[FC_REFILL_EXTERNAL_FAR]  @aParentFarID int, @UserID int, @mode int
AS
BEGIN
set nocount on

/*KB1447 обновляет "входные" параметры eFAR, которые заполняет FC_CREATE_EXTERNAL_FAR */

declare @externalFarID int

select top 1 @externalFarID = A.ID from FC_REPORT A with (nolock) where A.EXTPARENTID = @aParentFarID and A.S_S in (2130021 /*generated*/)

if @externalFarID is null 
begin
  set nocount off
  return 
end  
 
update A set 
 	 A.FAILUREDATE = B.FAILUREDATE
    ,A.WARRANTY = B.WARRANTY
    ,A.RMA_TYPE = B.RMA_TYPE
    ,A.RMA = B.RMA
    ,A.OTHERRMA = B.OTHERRMA
    ,A.FROMDEPID = B.FROMDEPID
    ,A.FROMCUSTOMERID = B.FROMCUSTOMERID
    ,A.DEVICEID = B.DEVICEID
    ,A.QUANTITY = B.QUANTITY
    ,A.OPERTIME = B.OPERTIME
    ,A.CUSTREF = B.CUSTREF
    ,A.FAILUREDESCRIPTION = B.FAILUREDESCRIPTION
    ,A.REQUESTEDACTIONS = B.REQUESTEDACTIONS
    ,A.MODELID = B.MODELID
    ,A.SN = B.SN
    ,A.INT_EXT = B.INT_EXT
    ,A.USER3DT = B.USER3DT
    ,A.DATE_PRODUCT3 = B.DATE_PRODUCT3
    ,A.CORR_ACTION_DATE = B.CORR_ACTION_DATE
    ,A.CORRECTIVE_ACTION = B.CORRECTIVE_ACTION
    ,A.ACTIONPOINTS = B.ACTIONPOINTS
    ,A.OFFICEID = B.OFFICEID
    ,A.BATCHN = B.BATCHN
    ,A.REMARK = B.REMARK
    ,A.INTERNALREMARK = B.INTERNALREMARK
    ,A.USER1DT = B.USER1DT
from FC_REPORT A
left join FC_REPORT B on B.ID = A.EXTPARENTID
where A.ID = @externalFarID

exec FC_GEN_NEXT_FRNUM @externalFarID, 0

delete from FC_REPORT_FILES 
where VNESHID = @externalFarID

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
            , @externalFarID
        from FC_REPORT_FILES
        where VNESHID=@aParentFarID


set nocount off

END