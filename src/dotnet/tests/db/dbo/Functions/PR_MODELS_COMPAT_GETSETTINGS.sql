create function [dbo].[PR_MODELS_COMPAT_GETSETTINGS] (@DepID int, @UserID int, @Mode int)
returns @res table (ID int)
as 
begin



   insert into @res (ID) 
   select A.ID from PR_MODELTYPE A with (nolock) where A.DEPARTMENTID = @DepID
   
   
   declare @emplid int
   set @emplid = dbo.DEF_EMPLOYEE(@UserID)
   
   insert into @res (ID) 
   select B.MTID
   from PR_MODEL_COMPAT_SETTINGS A with (nolock)
   left join PR_MODEL_COMPAT_SETTINGS_MT B with (nolock) on B.VNESHID = A.ID
   where A.DEPID = @DepID
     and exists (select J.ID from PR_MODEL_COMPAT_SETTINGS_MT_E J with (nolock) where J.VNESHID = A.ID  and J.EMPLID = @emplid)

   return 
    
end