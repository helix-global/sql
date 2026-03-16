create function [dbo].[PR_RMA_CUT_LASTPART2](@aNN nvarchar(20),@DepID int, @ModelID int, @aMode int)
returns nvarchar(20) as  
begin
  declare @res nvarchar(20) = @aNN
  
  declare @mtid int
  
  select @mtid = A.TYPEID 
  from PR_MODELS A with (nolock)
  where A.ID = @ModelID
  
  declare @settingID int
  
  select top 1 @settingID = A.ID 
  from PR_NAV_DEPMODES A with (nolock)
  where A.DEPID = @DepID
    and A.MTID = @mtid
    
  if @settingID is null
  begin
	  select top 1 @settingID = A.ID 
	  from PR_NAV_DEPMODES A with (nolock)
	  where A.DEPID = @DepID
		and A.MTID is null
  end  
  
  if @settingID is null
  begin
     
     return @aNN 
     
  end
  
  declare @needCut int = null
  select top 1 @needCut = A.CUTRMAAFTERDOT
  from PR_NAV_DEPMODES_T A with (nolock)
  where A.VNESHID = @settingID
    and A.MODELID = @ModelID
  
  if @needCut is null
  begin
  
	  select top 1 @needCut = A.CUTRMAAFTERDOT
	  from PR_NAV_DEPMODES A with (nolock)
	  where A.ID = @settingID
  
  end
  
  if @needCut = 1
    set @res = dbo.PR_RMA_CUT_LASTPART(@aNN, @aMode)
  
  
  return @res
end