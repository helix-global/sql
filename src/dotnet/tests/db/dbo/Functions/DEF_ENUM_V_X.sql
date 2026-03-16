create function [dbo].[DEF_ENUM_V_X](@EnumOID int,@EnumLabel nvarchar(100),@Code int,@aLangCode nvarchar(2))
returns nvarchar(300) as 
begin
  declare @res nvarchar(300)
  
  if @EnumOID is not null
     select @res = A.NAME 
       from DEF_ENUMERATION_T A with (nolock) 
      where A.ENUMOID = @EnumOID and A.CODE = @Code
  else
     select @res = A.NAME 
       from DEF_ENUMERATION_T A with (nolock) 
       left join DEF_ENUMERATION B with (nolock) on B.OID = A.ENUMOID
      where B.LABEL = @EnumLabel and A.CODE = @Code       
      
  declare @i int
  set @i = CHARINDEX('[',@res)
  if @i > 0 
  begin
     set @res = dbo.COM_LANG_X(@res,@aLangCode)
  end      
      
  return @res
end