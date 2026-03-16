CREATE function [dbo].[SL_MODEL_FILES_TAB_WITH_BLOB] (@ModelID int)
returns @res table (ID int
                    , GID uniqueidentifier
                    , S_CR int
                    , S_CDT datetime
                    , S_MR int
                    , S_MDT datetime
                    , MODELID int
                    , FILENAME nvarchar(255)
                    , FILEDATE datetime
                    , FILESIZE int
                    , FILEDESC ntext
                    , FILESOURCE int
                    , FILEGROUP int
                    , FILESOURCEID int
                    , FILEBLOB IMAGE)
as 
begin

insert into @res (ID,S_CR,S_CDT,S_MR,S_MDT,GID,MODELID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP, FILESOURCE, FILEBLOB)
SELECT A.ID,A.S_CR,A.S_CDT,A.S_MR,A.S_MDT, A.GID, A.MODELID, A.FILENAME, A.FILEDATE, A.FILESIZE, A.FILEDESC, A.FILEGROUP, 1, A.FILEBLOB
FROM dbo.PR_MODEL_FILES AS A WITH (nolock) 
LEFT JOIN dbo.PR_MODELS AS B WITH (nolock) ON B.ID = A.MODELID
WHERE (B.TYPEID IN (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (B.S_S IN (1000016, 1000003)) /*approved,deprecated*/
  AND (ISNULL(B.PRTYPE, 0) IN (1, 2))
  and A.SWID is null 
  and (@ModelID is null or A.MODELID=@ModelID)


insert into @res (ID,GID,S_MDT,MODELID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP,FILESOURCE,FILESOURCEID,FILEBLOB)
select A.ID,T.GID
   ,(select max(K.S_MDT) from SW_TOOL_VER_FILES K where K.VERID = H.ID ) as S_MDT
   ,A.MODELID,T.NAME+'.zip'
   ,H.S_MDT as FILEDATE
   ,(select sum(K.FILESIZE) from SW_TOOL_VER_FILES K where K.VERID = H.ID) as FILESIZE
   ,A.FILEDESC
   ,A.FILEGROUP,2,H.ID
   ,A.FILEBLOB
FROM dbo.PR_MODEL_FILES AS A WITH (nolock) 
LEFT JOIN dbo.PR_MODELS AS M WITH (nolock) ON M.ID = A.MODELID
left join dbo.SW_TOOLS as T with (nolock) on T.ID = A.SWID
left join dbo.SW_TOOL_VERSIONS H with (nolock) on H.ID = dbo.SW_TOOL_LATEST_VER(A.SWID, null)
WHERE (M.TYPEID IN (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (M.S_S IN (1000016, 1000003)) /*approved,deprecated*/
  AND (ISNULL(M.PRTYPE, 0) IN (1, 2))
  and A.SWID is not null
  and H.ID is not null
  and (@ModelID is null or A.MODELID=@ModelID)
  

return

end