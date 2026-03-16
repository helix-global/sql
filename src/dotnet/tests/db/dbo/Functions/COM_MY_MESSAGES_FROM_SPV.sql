CREATE function [dbo].[COM_MY_MESSAGES_FROM_SPV](@UserID int, @aMode int)  
 returns table 
as 
return 
  select B.ID, B.GID, B.S_CR, B.S_CDT, B.S_MR, B.S_MDT,  B.DD, B.MESS, B.DEPID, A.READED
       , case when A.READED is null then 1000185 /*новое*/ else 1000186 /*прочитано*/ end as S_S
       , case when cast(B.DD as date) = cast(getdate() as date) then 1 
              when dbo.COM_SAMEWEEK(B.DD,getdate()) = 1 then 10
              when year(B.DD) = year(getdate()) and month(B.DD) = month(getdate()) then 20
              else 100 end as DDGROUP
       , (select count(*) from COM_SPV_MESSAGE_FILES FF with (nolock) where FF.VNESHID = B.ID) as ATTACHMENTS
  from COM_MESSAGE_EMPL A with (nolock)
  left join COM_SPV_MESSAGE B with (nolock) on B.ID = A.VNESHID
  where A.EMPLID = dbo.DEF_EMPLOYEE(@UserID) /*or @UserID = 3*/
    and (isnull(B.UPVISIBLE,0) = 1 or isnull(@aMode,0) <> 1)
    and B.S_S > 1