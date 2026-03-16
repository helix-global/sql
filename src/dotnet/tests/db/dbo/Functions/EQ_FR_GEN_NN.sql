CREATE function [dbo].[EQ_FR_GEN_NN](@aDate datetime, @aMode int)
returns nvarchar(20) as 
begin
	
	declare @res nvarchar(20)
    
	declare @yy nvarchar(4)
	declare @mm nvarchar(2)
	declare @dd nvarchar(4)

	set @yy = LTRIM(str(datepart(yy,@aDate)))
	set @mm = LTRIM(str(datepart(mm,@aDate)))  
	set @dd = LTRIM(str(datepart(dd,@aDate)))    

	if (LEN(@yy) = 4)
	  set @yy = SUBSTRING(@yy,3,2)
	if (LEN(@mm) = 1)  
	  set @mm = '0'+@mm
	if (LEN(@dd) = 1)  
	  set @dd = '0'+@dd

    declare @pref nvarchar(20) = @yy+@mm+@dd+'-'
    declare @nextN int
    
    select @nextN = max(dbo.COM_EXTR_NUM_AFTER(A.FR_NN,@pref))
    from EQ_FR A with (nolock)
    where A.FR_NN like @pref+'%'
    
    set @nextN = isnull(@nextN,0) + 1
    
    declare @nextNstr nvarchar(11) = cast(@nextN as nvarchar(10))
    
    if (LEN(@nextNstr) = 1)  
	  set @nextNstr = '0'+@nextNstr

    set @res=@pref+@nextNstr
  
    return @res

end