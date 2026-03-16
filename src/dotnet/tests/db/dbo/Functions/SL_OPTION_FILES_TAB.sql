CREATE function [dbo].[SL_OPTION_FILES_TAB] ()
returns @res table (ID int
            , GID uniqueidentifier
            , S_CR int,S_CDT datetime
            , S_MR int
            , S_MDT datetime
            , OPTID int
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


insert into @res (ID,GID,S_CR,S_CDT,S_MR,S_MDT,OPTID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP, FILESOURCE, CRMGUID, TS)
SELECT A.ID, A.GID, A.S_CR, A.S_CDT, A.S_MR, A.S_MDT, A.OPTID, A.FILENAME, A.FILEDATE, A.FILESIZE, A.FILEDESC, A.FILEGROUP, 1, A.CRMGUID, A.TS
FROM PR_MODELTYPE_OPTIONS_FILES AS A WITH (nolock) 
LEFT JOIN PR_MODELTYPE_OPTIONS AS B WITH (nolock) ON B.ID = A.OPTID 
LEFT JOIN PR_MODELTYPE_OPTION_GR AS C WITH (nolock) ON C.ID = B.OPTGROUP
WHERE (C.TYPEID IN  (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (ISNULL(B.PRTYPE, 0) IN (1, 2, 3))
  AND A.SWID is null

/*
insert into @res (ID,GID,OPTID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP,FILESOURCE)
select F.ID,F.GID,A.OPTID,F.FILENAME,F.FILEDATE,F.FILESIZE,F.FILEDESC,A.FILEGROUP,2
FROM PR_MODELTYPE_OPTIONS_FILES AS A WITH (nolock) 
cross apply dbo.SW_GET_TOOL_FILES (A.SWID,0) FF
left join SW_TOOL_VER_FILES F on F.ID = FF.ID
LEFT JOIN PR_MODELTYPE_OPTIONS AS B WITH (nolock) ON B.ID = A.OPTID 
LEFT JOIN PR_MODELTYPE_OPTION_GR AS C WITH (nolock) ON C.ID = B.OPTGROUP
WHERE (C.TYPEID IN  (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (ISNULL(B.PRTYPE, 0) IN (1, 2, 3))
  AND A.SWID is not null
  and F.ID is not null
*/

insert into @res (ID,GID,S_MDT,OPTID,FILENAME,FILEDATE,FILESIZE,FILEDESC,FILEGROUP,FILESOURCE,FILESOURCEID, CRMGUID, TS)
select A.ID,T.GID
   ,(select max(K.S_MDT) from SW_TOOL_VER_FILES K where K.VERID = H.ID) as S_MDT
   ,A.OPTID,T.NAME+'.zip'
   ,H.S_MDT as FILEDATE
   ,(select sum(K.FILESIZE) from SW_TOOL_VER_FILES K where K.VERID = H.ID) as FILESIZE
   ,A.FILEDESC
   ,A.FILEGROUP,2,H.ID,G.CRMGUID, H.TS
FROM PR_MODELTYPE_OPTIONS_FILES AS A WITH (nolock) 
LEFT JOIN PR_MODELTYPE_OPTIONS AS B WITH (nolock) ON B.ID = A.OPTID 
LEFT JOIN PR_MODELTYPE_OPTION_GR AS C WITH (nolock) ON C.ID = B.OPTGROUP
left join dbo.SW_TOOLS as T with (nolock) on T.ID = A.SWID
left join dbo.SW_TOOL_VERSIONS H with (nolock) on H.ID = dbo.SW_TOOL_LATEST_VER(A.SWID, null)
left join SL_OPTION_ZIPFILE_GUIDS G with(nolock) on B.ID=G.OPTID and G.SW_TOOL_VER_ID=H.ID
WHERE (C.TYPEID IN  (SELECT MTID FROM dbo.PR_MT4CONFIG)) 
  AND (ISNULL(B.PRTYPE, 0) IN (1, 2, 3))
  AND A.SWID is not null
  and H.ID is not null


return

end