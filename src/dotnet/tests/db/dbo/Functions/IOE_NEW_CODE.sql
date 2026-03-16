CREATE function [dbo].[IOE_NEW_CODE](@aMode int,@dd datetime,@skipID int)
returns nvarchar(50) as 
begin

/*
KB3856
OHC-#######-MM-YY
*/

  declare @res nvarchar(50)
  declare @maxN int
  
  declare @now datetime = @dd
  if @now is null
    set @now = getdate()

  declare @yy nvarchar(2) = substring(rtrim(ltrim(cast(year(@now) as nvarchar))),3,2)
  declare @mm nvarchar(2) = dbo.COM_PAD_LEFT(rtrim(ltrim(cast(month(@now) as nvarchar))),'0',2)
  
    
  
  select @maxN = max(dbo.COM_EXTR_NUM(A.CODE,5,7)) from IOE_CHAPTER A where A.CODE like 'OHC-_______-__-__' and A.ID <> ISNULL(@skipID,-444)
  set @maxN = isnull(@maxN,0)
  set @res = 'OHC-'+dbo.COM_PAD_LEFT(STR(@maxN+1),'0',7)+'-'+@mm+'-'+@yy
  
  return @res;
end