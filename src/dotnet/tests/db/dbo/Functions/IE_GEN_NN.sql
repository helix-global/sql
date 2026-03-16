create function [dbo].[IE_GEN_NN](@aDate datetime, @aMode int)
returns nvarchar(20) as 
begin
	
	declare @res nvarchar(20)
    
	declare @yy nvarchar(4)
	declare @mm nvarchar(2)

	set @yy = LTRIM(str(datepart(yy,@aDate)))
	set @mm = LTRIM(str(datepart(mm,@aDate)))  

	if (LEN(@yy) = 4)
	  set @yy = SUBSTRING(@yy,3,2)
	if (LEN(@mm) = 1)  
	  set @mm = '0'+@mm

    declare @pref nvarchar(20) = 'IE'+@yy+@mm
    declare @nextN int
    
    select @nextN = max(dbo.COM_EXTR_NUM_AFTER(A.NN,@pref))
    from IE_IE A with (nolock)
    where A.NN like @pref+'%'
    
    set @nextN = isnull(@nextN,0) + 1
    
    declare @nextNstr nvarchar(11) = cast(@nextN as nvarchar(10))
    
    while (LEN(@nextNstr) < 5)  
	  set @nextNstr = '0'+@nextNstr

    set @res=@pref+@nextNstr
  
    return @res

end