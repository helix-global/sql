CREATE function [dbo].[MSG_SUBSCRIPTION_FILES_EXISTS](@aScrMessID int)
returns int as 
begin

  /*
  проверяет что по подписке все обязательные файлы есть 
  */
  if exists (
          select T.ID
          from MSG_FILENOTIFICATIONS_OUT A with (nolock)
          left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
          left join MSG_FILENOTIFICATION_T T with (nolock) on T.VNESHID = B.ID
          where A.ID = @aScrMessID
            and isnull(T.FILEREQUIRED,0) = 1
            and not exists (select J.ID from MSG_FILENOTIFICATIONS_OUT_FILES J where J.VNESHID = A.ID and J.PARAMID = T.PARAMID)
           )
           or
    exists (
          select T.ID
          from MSG_FILENOTIFICATIONS_OUT A with (nolock)
          left join MSG_FILENOTIFICATIONS B with (nolock) on B.ID = A.SBSCID
          left join MSG_FILENOTIFICATION_B T with (nolock) on T.VNESHID = B.ID
          where A.ID = @aScrMessID
            and isnull(T.FILEREQUIRED,0) = 1
            and not exists (select J.ID from MSG_FILENOTIFICATIONS_OUT_FILES J where J.VNESHID = A.ID and J.PARAMID = T.PARAMID)
           )
      return 0;
     
     
  return 1;
     
end