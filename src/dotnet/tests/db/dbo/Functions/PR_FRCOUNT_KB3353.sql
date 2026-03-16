CREATE function [dbo].PR_FRCOUNT_KB3353(@deviceID int, @fraCodes nvarchar(max))
returns int as 
/* KB3353  ищет имеющиеся FAR по перечисленным кодам анализа и возвращает количество таких FAR*/
begin
  
  declare @res int = 0
  
  if len(@fraCodes) > 0
  begin
  
     select @res = count(A.ID)
     from FC_REPORT_ANALYSIS_CODES A with(nolock)
     left join FC_REPORT B with(nolock) on B.ID = A.VNESHID
     where B.DEVICEID = @deviceID
       and A.ANALYSISCODEID in (select ID from dbo.COM_STR2TABLE_INT(@fraCodes))
  
  end

  return @res;
end