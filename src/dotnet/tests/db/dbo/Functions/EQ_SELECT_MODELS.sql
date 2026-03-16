CREATE function [dbo].[EQ_SELECT_MODELS] (@aUserID int,@aMode int,@aDate datetime)
returns table 
as return
  select A.ID 
  from EQ_MODELS A with (nolock) 
  left join EQ_TYPES B with (nolock) on B.ID = A.EQTYPEID
  where A.DEPID in (SELECT ID FROM dbo.COM_ACCESS_DEPARTMENTS(@aUserID, @aMode, @aDate))
     or B.SHAREDTYPE = 1