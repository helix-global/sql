CREATE FUNCTION [dbo].[WEB_FIND_DEVICEID](@UserID int, @aCode nvarchar(16), @aSN nvarchar(50))
RETURNS int
AS
BEGIN
  
  declare @res int
  declare @userDepID int = dbo.COM_DEPARTMENT2(@UserID)
  
  if (@userDepID=160 /*LDM*/) /*20.11.2018 Запрос от А.Ходакова на видимость только своих изделий*/
  begin
    select @res = A.ID
    from PR_DEVICE A with (nolock) 
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
    where B.CODE like @aCode
      and A.SN = @aSN
      and B.DEPID <> 222 /* (IPGP Packaging) диодные модули часто совпадают по серийным номерам, а утилиты LDM не могут фильтровать по модели  */
      and A.MODELID in (select ID from dbo.PR_ACCESS_MODELS(@UserID,3,getdate()))
  
    return @res;  
  end
    
  select @res = A.ID
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where B.CODE like @aCode
    and A.SN = @aSN
    and B.DEPID <> 222 /* (IPGP Packaging) диодные модули часто совпадают по серийным номерам, а утилиты LDM не могут фильтровать по модели  */
    and A.MODELID in (select J.ID from dbo.PR_VIEWMODEL_TAB(@UserID,getdate()) J)
  
  if (@res is not null)
  begin
    return @res;  
  end
    
  select @res = A.ID
  from PR_DEVICE A with (nolock) 
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID 
  where B.CODE like @aCode
    and A.SN = @aSN
    and B.DEPID <> 222 /* (IPGP Packaging) диодные модули часто совпадают по серийным номерам, а утилиты LDM не могут фильтровать по модели  */
    and A.MODELID in (select ID from dbo.PR_ACCESS_MODELS(@UserID,4,getdate()))
  
  return @res;  

END