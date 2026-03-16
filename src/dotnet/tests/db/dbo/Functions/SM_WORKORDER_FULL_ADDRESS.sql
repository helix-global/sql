create FUNCTION [dbo].[SM_WORKORDER_FULL_ADDRESS] (@woID int, @aMode int)
RETURNS nvarchar(max)
AS
BEGIN

  declare @res nvarchar(max) = ''
  
  declare @code nvarchar(50)
  declare @city nvarchar(150)
  declare @street nvarchar(150)
  
  select @code = A.ADR_CODE
       ,@city = A.ADR_CITY
       ,@street = A.ADR_STREET
  from SM_WORKORDER A with (nolock)
  where A.ID = @woID       
  
  if @code is not null
    set @res = @res + @code
    
  if @city is not null
  begin
    if len(@res) > 0
      set @res = @res + ', '
    set @res = @res + @city
  end  

  if @street is not null
  begin
    if len(@res) > 0
      set @res = @res + ', '
    set @res = @res + @street
  end  

  
  return @res

END