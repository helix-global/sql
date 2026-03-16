CREATE FUNCTION [dbo].[WEB_FIND_OPERATION_2_JOIN](@UserID int, @aCode nvarchar(16), @aSN nvarchar(50), @aOrder nvarchar(50), @aOperationCode nvarchar(50))
RETURNS int
AS
BEGIN
  
  
  declare @items table (ID int not null)
  insert into @items (ID)
  select A.ID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  where A.SN = @aSN
    and B.CODE like @aCode
    and A.S_S in (1000008/*in prod*/,1000029/*pending prod*/,1000011/*in serv*/,1000077/*Installed*/)
  
  
  declare @res int
  
  select top 1 @res = A.ID
  from PR_OPERATION A with (nolock) 
  left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
  left join PR_OPERATIONS D with (nolock) on D.ID = A.OPERTYPEID
  left join PR_PRORDER R with (nolock) on R.ID = A.ORDERID
  where A.DEVICEID in (select ID from @items)
    and (B.ORDERID is null or B.ORDERID = A.ORDERID) /* только производственные заказы */
    and A.ID in (select GG.ID from dbo.WEB_IS_MY_CO_AJOIN(@UserID,getdate()) GG)
    and D.CODE = @aOperationCode
    and (B.S_S in (1000008/*in prod*/,1000029/*pending prod*/) or (B.S_S = 1000077/*Installed*/ and B.ORDERID is null))
    and (R.NN = @aOrder or @aOrder = '%' or @aOrder = '*')
    
  if @res is null
  begin
   
    /* если не найдена в производственных - поискать в сервисных */
      select top 1 @res = A.ID
      from PR_OPERATION A with (nolock) 
      left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
      left join PR_OPERATIONS D with (nolock) on D.ID = A.OPERTYPEID
      left join PR_PRORDER R with (nolock) on R.ID = A.ORDERID
      where A.DEVICEID in (select ID from @items)
        and isnull(B.ORDERID,0) <> A.ORDERID /* серв заказы */
        and A.ID in (select GG.ID from dbo.PR_IS_MY_CO_AJOIN(@UserID,getdate()) GG)
        and D.CODE = @aOperationCode
        and B.S_S in (1000011/*in serv*/)
        and (R.NN = @aOrder or @aOrder = '%' or @aOrder = '*')
  
  end    
  
  return @res;

END