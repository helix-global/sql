CREATE function [dbo].[MSG_SUBSCRIPTION_FILES_NOTEXISTS_NAMES](@aScrMessID int)
returns nvarchar(max) as 
begin

  /*
  Выдает имена параметров, по которым в подписке нет обязательных файлов
  */

  declare @res nvarchar(max) = 'Item files: <br>'

  select @res = @res + P.NAME + '<br>'
  from MSG_FILENOTIFICATIONS_OUT A with (nolock)
  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
  left join MSG_FILENOTIFICATION_T T with (nolock) on T.VNESHID = B.ID
  left join PR_MODELTYPE_PARAMS P with (nolock) on P.ID = T.PARAMID
  where A.ID = @aScrMessID
    and isnull(T.FILEREQUIRED,0) = 1
    and not exists (select J.ID from MSG_FILENOTIFICATIONS_OUT_FILES J with (nolock) where J.VNESHID = A.ID and J.PARAMID = T.PARAMID)

    set @res = @res + 'BOM Item files: <br>' 

  select @res = @res + P.NAME + '<br>'
  from MSG_FILENOTIFICATIONS_OUT A with (nolock)
  left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
  left join MSG_FILENOTIFICATION_B T with (nolock) on T.VNESHID = B.ID
  left join PR_MODELTYPE_PARAMS P with (nolock) on P.ID = T.PARAMID
  where A.ID = @aScrMessID
    and isnull(T.FILEREQUIRED,0) = 1
    and not exists (select J.ID from MSG_FILENOTIFICATIONS_OUT_FILES J with (nolock) where J.VNESHID = A.ID and J.PARAMID = T.PARAMID)
     
  return @res   
     
end