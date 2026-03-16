CREATE function [dbo].[PR_DOC_FILES] (@aDoCID int, @aDocGID uniqueidentifier, @aUserID int)
returns @res table (ID int identity,DOCID int,FILENAME nvarchar(255),FILEDATE datetime, FILESIZE int, FILEPREVIEW image, FILEGROUP nvarchar(200), FILEDESC nvarchar(200), FILEBLOB image)
as 
begin

/*

TODO !!! должно передаваться GID для уточнения строчки. Т.к. view PR_DOC_ALL состоит из union двух таблиц, то ID могут пересекаться 
Версии A2Client.dll > 30.11.2018 помимо @DocumentID формируют параметр @DocumnentGID, который надо передавать в @aDocGID

*/
 
  insert into @res(DOCID,FILENAME,FILEDATE, FILESIZE,  FILEPREVIEW, FILEGROUP, FILEDESC, FILEBLOB)
  select A.ID,B.FILENAME,B.FILEDATE,B.FILESIZE,B.FILEPREVIEW,null,B.FILEDESC,B.FILEBLOB
  from PR_DOC_BYOPERATIONS A with (nolock)
  left join PR_OPERATION C with (nolock) on C.ID = A.OPERID
  left join PR_OPERATION_FILES B with (nolock) on B.ID = A.FILEID
  where A.ID = @aDocID
    /*and A.GID = @aDocGID   TODO РАССКОМЕНТАРИТЬ НА  A2Client.dll > 30.11.2018 */
    and A.FILEID is not null
  
  insert into @res(DOCID,FILENAME,FILEDATE, FILESIZE,  FILEPREVIEW, FILEGROUP, FILEDESC, FILEBLOB)
  select A.ID,B.FILENAME,B.FILEDATE,B.FILESIZE,B.FILEPREVIEW,null,B.FILEDESC,B.FILEBLOB
  from SW_TOOLS A with (nolock)
  left join SW_TOOL_VER_FILES B with (nolock) on B.VERID = (select top 1 G.ID 
                                                              from SW_TOOL_VERSIONS G with (nolock) 
                                                             where G.TOOLID = A.ID 
                                                               and G.S_S in (1000061)/*approved*/
                                                             order by G.ID desc
                                                            )
  where A.GROUPID in (select SWGROUP from PR_DOC_SETTINGS with (nolock))
    and A.ID = @aDocID
    /*and A.GID = @aDocGID   TODO РАССКОМЕНТАРИТЬ НА  A2Client.dll > 30.11.2018 */
    and B.ID is not null
    



return

end