
create function dbo.PR_OPT_SN(@OptSNMask nvarchar(20), @DeviceSN nvarchar(50))
returns nvarchar(70) as 
begin
  if @OptSNMask is null 
    return null
  return replace(@OptSNMask,'%',@DeviceSN) 
end