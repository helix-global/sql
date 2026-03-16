CREATE procedure [dbo].[SL_APPROVE_PRODUCT] @aID int, @aUserID int , @aMode int
as 
set nocount on

update SL_MODELS
   set S_CR = B.S_CR
      ,S_CDT = B.S_CDT
      ,S_MR  = B.S_MR
      ,S_MDT = B.S_MDT
      ,S_S = B.S_S
      ,CODE = B.CODE
      ,DEPID = B.DEPID
      ,NAME = B.NAME
      ,DESCSTR = B.DESCSTR
      ,TYPEID = B.TYPEID
      ,TAGS = B.TAGS
      ,PRTYPE = B.PRTYPE
      ,MPICT = B.MPICT
      ,SPEC = B.SPEC
      ,CUSTOM4GROUP  = B.CUSTOM4GROUP
      ,CUSTOM4ID  = B.CUSTOM4ID
      ,APPROVEDBY = @aUserID
      ,APPROVEDDT = getdate()
from SL_MODELS A
left join SL_MODELS_V B on B.ID = A.ID
where A.ID = @aID

if @@rowcount = 0
begin
    insert into SL_MODELS (
        ID
        ,GID
        ,S_CR
        ,S_CDT
        ,S_MR
        ,S_MDT
        ,S_S
        ,CODE
        ,DEPID
        ,NAME
        ,DESCSTR
        ,TYPEID
        ,TAGS
        ,PRTYPE
        ,MPICT
        ,SPEC
        ,CUSTOM4GROUP
        ,CUSTOM4ID
        ,APPROVEDBY
        ,APPROVEDDT
        )
    select ID
        ,GID
        ,S_CR
        ,S_CDT
        ,S_MR
        ,S_MDT
        ,S_S
        ,CODE
        ,DEPID
        ,NAME
        ,DESCSTR
        ,TYPEID
        ,TAGS
        ,PRTYPE
        ,MPICT
        ,SPEC
        ,CUSTOM4GROUP
        ,CUSTOM4ID
        ,@aUserID
        ,getdate()
    from SL_MODELS_V where ID = @aID
end

delete from SL_MODEL_OPTIONS where MODELID = @aID

insert into SL_MODEL_OPTIONS (
    ID
    ,GID
    ,S_CR
    ,S_CDT
    ,S_MR
    ,S_MDT
    ,OPTIONID
    ,MODELID
    ,PREDEFINEDOPT
    ,CODE
    ,NAME
    ,GROUPNAME
    ,OVERPTYPE
    ,CUSTOM4GROUP
    ,CUSTOM4ID
    ,PRTYPE_OVERRIDE
    ,PRTYPE
    ,CMP_OUT2_OVERRIDE
    ,CMP_OUT2
    ,CMP_BLOCK_OVERRIDE
    ,CMP_BLOCK
    ,CMP_REQ_OVERRIDE
    ,CMP_REQ
    )
select ID
    ,GID
    ,S_CR
    ,S_CDT
    ,S_MR
    ,S_MDT
    ,OPTIONID
    ,MODELID
    ,PREDEFINEDOPT
    ,CODE
    ,NAME
    ,GROUPNAME
    ,OVERPTYPE
    ,CUSTOM4GROUP
    ,CUSTOM4ID
    ,PRTYPE_OVERRIDE
    ,PRTYPE
    ,CMP_OUT2_OVERRIDE
    ,CMP_OUT2
    ,CMP_BLOCK_OVERRIDE
    ,CMP_BLOCK
    ,CMP_REQ_OVERRIDE
    ,CMP_REQ
from SL_MODEL_OPTIONS_V where MODELID = @aID

delete from SL_MODEL_FILES where MODELID = @aID

insert into SL_MODEL_FILES (ID,GID,S_CR,S_CDT,S_MR,S_MDT,MODELID,FILENAME,FILESIZE,FILEDATE,FILEBLOB,FILEDESC,FILEGROUP,FILESOURCE,FILESOURCEID)
select ID,GID,S_CR,S_CDT,S_MR,S_MDT,MODELID,FILENAME,FILESIZE,FILEDATE,FILEBLOB,FILEDESC,FILEGROUP,FILESOURCE,FILESOURCEID 
from SL_MODEL_FILES_V where MODELID = @aID

delete from SL_REQ_OPTIONS where MODELID = @aID

insert into SL_REQ_OPTIONS (ID,S_CR,S_CDT,S_MR,S_MDT,MODELID,OPTIONGRID,OPTIONGRID2,OPTIONGRID3,OPTIONGRID4,OPTIONGRID5,GRNAME,GR2NAME,GR3NAME,GR4NAME,GR5NAME)
select ID,S_CR,S_CDT,S_MR,S_MDT,MODELID,OPTIONGRID,OPTIONGRID2,OPTIONGRID3,OPTIONGRID4,OPTIONGRID5,GRNAME,GR2NAME,GR3NAME,GR4NAME,GR5NAME 
from SL_REQ_OPTIONS_V where MODELID = @aID

set nocount off