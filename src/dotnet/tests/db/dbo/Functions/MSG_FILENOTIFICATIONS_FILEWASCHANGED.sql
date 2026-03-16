create function [dbo].[MSG_FILENOTIFICATIONS_FILEWASCHANGED](@aScrDocID int)
returns int as 
begin

  /*
  проверяет что по документу подписки файлы изменились
  */
  if exists (
  
	  select A.ID
		from MSG_FILENOTIFICATIONS_OUT_FILES A with (nolock)
		left join MSG_FILENOTIFICATIONS_OUT B with (nolock) on B.ID = A.VNESHID
	   cross apply dbo.PR_DEVICE_PARAM_FILES(B.DEVICEID, A.PARAMID) F
	   where A.VNESHID = @aScrDocID
		 and B.S_S = 1000178 /*wait for NAV*/
		 and F.ID is not null
		 and checksum(cast(A.FILEBLOB as varbinary(max))) <> checksum(cast(F.FILEBLOB as varbinary(max)))
		 
  )
   return 1;
     
     
  return 0;
     
end