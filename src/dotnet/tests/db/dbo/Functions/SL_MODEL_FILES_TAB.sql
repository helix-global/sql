CREATE function [dbo].[SL_MODEL_FILES_TAB] ()
returns @res table (ID int
                , GID uniqueidentifier
                , S_CR int
                ,S_CDT datetime
                ,S_MR int
                ,S_MDT datetime
                , MODELID int
                , FILENAME nvarchar(255)
                , FILEDATE datetime
                , FILESIZE int
                , FILEDESC ntext
                , FILESOURCE int
                , FILEGROUP int
                , FILESOURCEID int
                , CRMGUID uniqueidentifier
                , TS binary(8))
as 
begin

if dbo.DEF_USERINGROUP6('SST') = 1 /* членство в группе Sales Support Team отключает все файлы */
  return

insert into @res (ID,S_CR,S_CDT,S_MR,S_MDT,GID,MODELID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP, FILESOURCE, CRMGUID, TS)
SELECT A.ID,A.S_CR,A.S_CDT,A.S_MR,A.S_MDT, A.GID, A.MODELID, A.FILENAME, A.FILEDATE, A.FILESIZE, A.FILEDESC, A.FILEGROUP, 1, A.CRMGUID, A.TS
FROM dbo.PR_MODEL_FILES AS A WITH (nolock) 
LEFT JOIN dbo.PR_MODELS AS B WITH (nolock) ON B.ID = A.MODELID
WHERE (B.TYPEID IN (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (B.S_S IN (1000016, 1000003)) /*approved,deprecated*/
  AND (ISNULL(B.PRTYPE, 0) IN (1, 2))
  and A.SWID is null


insert into @res (ID,GID,S_MDT,MODELID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP,FILESOURCE,FILESOURCEID, CRMGUID, TS)
select A.ID,T.GID
   ,(select max(K.S_MDT) from SW_TOOL_VER_FILES K where K.VERID = H.ID ) as S_MDT
   ,A.MODELID,T.NAME+'.zip'
   ,H.S_MDT as FILEDATE
   ,(select sum(K.FILESIZE) from SW_TOOL_VER_FILES K where K.VERID = H.ID) as FILESIZE
   ,A.FILEDESC
   ,A.FILEGROUP,2,H.ID,G.CRMGUID,H.TS
FROM dbo.PR_MODEL_FILES AS A WITH (nolock) 
LEFT JOIN dbo.PR_MODELS AS M WITH (nolock) ON M.ID = A.MODELID
left join dbo.SW_TOOLS as T with (nolock) on T.ID = A.SWID
left join dbo.SW_TOOL_VERSIONS H with (nolock) on H.ID = dbo.SW_TOOL_LATEST_VER(A.SWID, null)
left join SL_MODEL_ZIPFILE_GUIDS G with(nolock) on M.ID=G.MODELID and G.SW_TOOL_VER_ID=H.ID
WHERE (M.TYPEID IN (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (M.S_S IN (1000016, 1000003)) /*approved,deprecated*/
  AND (ISNULL(M.PRTYPE, 0) IN (1, 2))
  and A.SWID is not null
  and H.ID is not null
  

return

end