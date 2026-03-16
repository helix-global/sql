create function [dbo].[MAC_MACSTR](@aO1 tinyint, @aO2 tinyint, @aO3 tinyint, @aO4 tinyint, @aO5 tinyint, @aO6 tinyint)
returns nvarchar(50) as 
begin

  return FORMAT(@aO1,'x2')+'-'+FORMAT(@aO2,'x2')+'-'+FORMAT(@aO3,'x2')+'-'+FORMAT(@aO4,'x2')+'-'+FORMAT(@aO5,'x2')+'-'+FORMAT(@aO6,'x2')
  

end