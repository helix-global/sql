create VIEW [dbo].[SM_WORKORDER_TASK_FILES]
AS
select A.ID, 
        A.S_CDT,
        A.S_CR,
        A.S_MDT,
        A.S_MR,
        A.FILEBLOB,
        A.FILEDATE,
        A.FILEDESC,
        A.FILENAME,
        A.FILESIZE,
        A.FILEPREVIEW,
        A.GID,
        T.VNESHID as WORDERID
    from SM_SERVICETASK_FILES A
        join SM_WORKORDER_TASKS T on A.VNESHID=T.TASKID