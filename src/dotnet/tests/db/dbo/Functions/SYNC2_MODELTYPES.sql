
CREATE function [dbo].[SYNC2_MODELTYPES] (@aRemoteCode nvarchar(10),@aSourceCode nvarchar(10))
returns @res table (ID int)
as 
begin

insert into @res (ID)
select distinct GG.MTID 
  from SYNC2_MODELS_SETUP GG 
where GG.TOLOCATIONID in (select LL.ID from COM_REMOTE LL where LL.CODE = @aRemoteCode)
  and GG.DEPID in (select LF.ID from dbo.COM_GETREMOTE_DEPARTMENTS(@aSourceCode) LF)
  and GG.S_S = 1000169

return

end