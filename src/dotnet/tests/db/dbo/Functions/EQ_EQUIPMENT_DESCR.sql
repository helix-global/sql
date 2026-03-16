create function [dbo].[EQ_EQUIPMENT_DESCR](@EqID int, @aMode int)
returns nvarchar(max) as 
begin

  declare @res nvarchar(max)
  
  select @res = isnull(D.NAME,'')+char(13)+char(10)+isnull(C.NAME,'')+char(13)+char(10)+isnull(B.CODE,'')
  from EQ_EQUIPMENT A with (nolock)
  left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
  left join EQ_MANUFACTURER C with (nolock) on C.ID = B.MANUFACTURER
  left join EQ_TYPES D with (nolock) on D.ID = B.EQTYPEID
  where A.ID = @EqID
  
  set @res = replace(@res,char(13)+char(10)+char(13)+char(10),char(13)+char(10))
  
  return @res;  

end