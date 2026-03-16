CREATE function [dbo].[PRR_2WORKSHIFT_LETTER](@EmplID int, @yy int, @mm int, @dd int)
returns nvarchar(5) as 
begin

  declare @res nvarchar(5)
  declare @ddt date
  declare @turn int
  
  declare @checkDD date = dbo.COM_ENCODE_DATE(@yy,@mm,1)
  set @checkDD = dateadd(day,@dd-1,@checkDD)
  if month(@checkDD) <> @mm
    return null  
  
  set @ddt = dbo.COM_ENCODE_DATE(@yy,@mm,@dd)
  
  select @turn = A.WTURN from COM_TURNS A with(nolock) where A.EMPLID = @EmplID and A.DD = @ddt
  
  if @turn = 1
    set @res = 'F'
  else if @turn = 2
    set @res = 'S'
  else if @turn > 2
    set @res = 'N'
    
    
  declare @vacationDay int
  set @vacationDay = dbo.COM_IS_VACATIONDAY2(@ddt,@EmplID)
  
  /*если день выходной и отпуск - показывать отпуск или нет? */
  
  if @vacationDay = 1 
    set @res = 'A'
  else if @vacationDay = 2 /*утро*/  
    set @res = 'A/'+isnull(@res,'')
  else if @vacationDay = 3 
    set @res = isnull(@res,'')+'/A'
    
  
  return @res  

end