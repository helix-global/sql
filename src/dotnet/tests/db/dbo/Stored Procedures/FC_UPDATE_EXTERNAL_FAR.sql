CREATE PROCEDURE [dbo].[FC_UPDATE_EXTERNAL_FAR]  @aParentFarID int, @UserID int, @mode int
AS
BEGIN

set nocount on

declare @externalFarID int

select top 1 @externalFarID = A.ID from FC_REPORT A with (nolock) where A.EXTPARENTID = @aParentFarID and A.S_S in (2130020/*requested*/,2130021 /*generated*/)

if @externalFarID is null 
begin
  set nocount off
  return 
end  

declare @now datetime = getdate()
declare @translationTableID int

select @translationTableID = C.ID
from FC_REPORT A with (nolock)
left join PR_MODELS B with (nolock) on B.ID = A.MODELID
left join FC_EXT_TRANSLATION C with (nolock) on C.MTID = B.TYPEID and C.ENDDEPID = A.EXTREQDEPID
where A.ID = @externalFarID

/* переписать коды для надежности? */

delete from FC_REPORT_ANALYSIS_CODES where VNESHID = @externalFarID
delete from FC_REPORT_CODES where VNESHID = @externalFarID

insert into FC_REPORT_CODES (GID,S_CR,S_CDT,VNESHID,REPCODEID)
select newid(),A.S_CR,A.S_CDT,@externalFarID,A.REPCODEID
from FC_REPORT_CODES A with (nolock)
where A.VNESHID = @aParentFarID

declare @codesTrans table (SRC_FCODE int,REPCODEID int,SRC_ANALYSISCODEID int,DEST_FCODE int,DEST_ANALYSISCODEID int)

insert into @codesTrans(SRC_FCODE,REPCODEID,SRC_ANALYSISCODEID)
select A.FCODE,B.REPCODEID,A.ANALYSISCODEID
from FC_REPORT_ANALYSIS_CODES A with (nolock)
left join FC_REPORT_CODES B with (nolock) on B.ID = A.FCODE
where A.VNESHID = @aParentFarID

update @codesTrans 
set DEST_FCODE = (select B.ID 
                 from FC_REPORT_CODES B with (nolock) 
                where B.VNESHID = /*@aParentFarID*/ @externalFarID /* bug KB836*/ 
                  and B.REPCODEID = "@codesTrans".REPCODEID
                  )

update @codesTrans 
set DEST_ANALYSISCODEID = (select A.EXTCODEID 
                          from FC_EXT_TRANSLATION_T A with (nolock) 
                         where A.VNESHID = @translationTableID
                           and A.CODEID = "@codesTrans".SRC_ANALYSISCODEID
                         )  


insert into FC_REPORT_ANALYSIS_CODES (GID,S_CR,S_CDT,VNESHID,FCODE ,ANALYSISCODEID)
select newid(),@UserID,@now,@externalFarID,A.DEST_FCODE,A.DEST_ANALYSISCODEID
from @codesTrans A
where A.DEST_FCODE is not null
and A.DEST_ANALYSISCODEID is not null
 
update A set A.S_S = 2130021/*generated*/ 
   ,A.REPAIRDATE = B.REPAIRDATE
   ,A.AREMARK = B.AREMARK
   ,A.WARRANTYREPAIR = B.WARRANTYREPAIR
   ,A.CORRECTIVE_ACTION = B.CORRECTIVE_ACTION
   ,A.CORR_ACTION_DATE = B.CORR_ACTION_DATE
   ,A.RESULT_INC_INSP = B.RESULT_INC_INSP
   ,A.ACTIONPOINTS = B.ACTIONPOINTS
   ,A.INTERNALREMARK = B.INTERNALREMARK
   ,A.FAILURE_ANALYSIS=B.FAILURE_ANALYSIS
   ,A.USER3DT=B.USER3DT
   ,A.REMARK=B.REMARK
   ,A.DATE_PRODUCT3=B.DATE_PRODUCT3
from FC_REPORT A
left join FC_REPORT B on B.ID = A.EXTPARENTID
where A.ID = @externalFarID

    
    insert into FC_ANALYSIS_FILES ( FILEBLOB
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
            from FC_ANALYSIS_FILES
            where VNESHID=@aParentFarID

set nocount off

END