create function [dbo].[FC_REPORT_PARAM](@aRepID int,@aParamID int)
returns sql_variant as 
begin
   declare @res sql_variant
   select @res = A.PVALUE from FC_REPORT_PARAMS A with (nolock) where A.FRID = @aRepID and A.PARAMID = @aParamID
   return @res
end