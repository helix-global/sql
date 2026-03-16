CREATE function [dbo].[FC_REPORT_NUMBER2](@aRmaType int, @aRma nvarchar(50))
returns nvarchar(100) with schemabinding as 
begin
  
  if @aRmaType is null or @aRma is null 
    return null

	/*
	1	INT
	2	RMA
	3	SC
	4	SCAFF
	*/
  declare @res nvarchar(100)
  if @aRmaType = 1 
    set @res = 'INT'
  else if @aRmaType = 2
    set @res = 'RMA'
  else if @aRmaType = 3
    set @res = 'SC'
  else if @aRmaType = 4
    set @res = 'SCAFF'
    
  set @res = isnull(@res,'') + '-' + isnull(@aRma,'')
  
  return @res

end