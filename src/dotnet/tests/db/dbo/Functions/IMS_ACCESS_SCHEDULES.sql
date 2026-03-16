CREATE function [dbo].[IMS_ACCESS_SCHEDULES] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (ID int)
as 
begin


	if dbo.DEF_USERINGROUP7(@aUserID,'IMSFKB3514') = 1
	begin

	  insert into @res (ID) 
	  select A.ID 
	  from IMS_TRAINING_SCHEDULE A with (nolock) 

	end
	else
	begin
	  insert into @res (ID) 
	  select A.ID 
	  from IMS_TRAINING_SCHEDULE A with (nolock) 
	  left join IMS_TRAINING_PLAN T2130302 with (nolock) on T2130302.ID = A.PLANID
	  left join IMS_TRAINING_TYPE T2130292 with (nolock) on T2130292.ID = T2130302.TRTYPEID
	  where dbo.COM_DEP_ACCESS(null,T2130292.DEPID,@aMode,@aUserID,getdate()) = 1
	end  

    return

end