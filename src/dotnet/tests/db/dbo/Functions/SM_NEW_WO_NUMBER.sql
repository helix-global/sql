CREATE function [dbo].[SM_NEW_WO_NUMBER](@UserID int,@aServiceOrdID int,@aWoID int)
returns nvarchar(30) as 
begin
  declare @res nvarchar(30)
  declare @maxN int
  declare @soNN nvarchar(20)
  
  if @aWoID is not null
  begin
  
     select @maxN = dbo.COM_EXTR_NUM_AFTER(A.NN,'-WO') 
           ,@soNN = B.NN
     from SM_WORKORDER A 
     left join PR_PRORDER B with (nolock) on B.ID = A.SORDERID
     where A.ID = @aWoID
     
     set @res = ltrim(rtrim(isnull(@soNN,'?')))+'-WO'+dbo.COM_PAD_LEFT(STR(@maxN),'0',3)
     return @res
  
  end

  select @maxN = max(dbo.COM_EXTR_NUM_AFTER(A.NN,'-WO')) from SM_WORKORDER A where A.SORDERID = @aServiceOrdID
  set @maxN = isnull(@maxN,0)
  set @res = '-WO'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',3)
  
  select @soNN = B.NN from PR_PRORDER B with (nolock) where B.ID = @aServiceOrdID
  
  set @res = ltrim(rtrim(isnull(@soNN,'?')))+@res
  
  return @res;
end