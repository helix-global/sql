CREATE function [dbo].[PR_DEVICE_CANSERVICE_NEW](@aDeviceID int,@DepID int,@mode int)
returns int
as
begin
  /*
  новая проверка ( ModelType Sharing с контрагентами и странами) что @DepID может ремонтировать @aDeviceID
  
  @mode = 1 проверять и дочерние по отношению к @DepID подразделения
  
  */
  
  declare @deps table (ID int not null)
  if @mode = 1
  begin
	insert into @deps (ID) select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,1)
  end
  else
    insert into @deps (ID) values (@DepID)
  
  
  declare @mtid int
  declare @modelid int
  declare @customerid int
  declare @countryid int
  
  
  select @modelid = A.MODELID
	,@mtid = B.TYPEID
	,@customerid = H.ID
	,@countryid = D.ID
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_PRORDER C with (nolock) on C.ID = A.ORDERID
  left join PR_SUPPLY S with (nolock) on S.ID = A.SORDERID
  left join COM_CUSTOMER H with (nolock) on H.ID = isnull(S.CUSTOMERID,C.CUSTOMERID)
  left join COM_COUNTRIES D with (nolock) on D.ID = H.COUNTRY
  where A.ID = @aDeviceID
  
                
  declare @settID int
  
  /* ПО напрямую указанному изделию */
  
  select @settID = A.MTSHARINGID
  from PR_MODELTYPE_SHARING_DEPS A with (nolock)
  left join PR_MODELTYPE_SHARING_DEVICE B with (nolock) on B.MTSHARINGID = A.MTSHARINGID
  where A.DEPID in (select ID from @deps)
    and B.DEVICEID = @aDeviceID
    
  if @settID is not null
    return 1  
  
  /* ПО стране, если определены модели */
  
  select @settID = A.MTSHARINGID
  from PR_MODELTYPE_SHARING_DEPS A with (nolock)
  left join PR_MODELTYPE_SHARING_COUNTRIES B with (nolock) on B.MTSHARINGID = A.MTSHARINGID
  where A.DEPID in (select ID from @deps)
    and B.COUNTRYID = @countryid
    and exists (select GG.ID from PR_MODELTYPE_SHARING_MODELS GG with (nolock) where GG.MTSHARINGID = A.MTSHARINGID and GG.MODELID = @modelid)
    and not exists (select P.ID from PR_MODELTYPE_SHARING_COUNTRIES_EXCEPT_CUST P with (nolock) where P.MTSHARINGCOUNTRYID = B.ID and P.CUSTID = @customerid)
  
  if @settID is not null
    return 1  

  /* ПО стране, если НЕ определены модели */

  select @settID = A.MTSHARINGID
  from PR_MODELTYPE_SHARING_DEPS A with (nolock)
  left join PR_MODELTYPE_SHARING_COUNTRIES B with (nolock) on B.MTSHARINGID = A.MTSHARINGID
  where A.DEPID in (select ID from @deps)
    and B.COUNTRYID = @countryid
    and not exists (select GG.ID from PR_MODELTYPE_SHARING_MODELS GG with (nolock) where GG.MTSHARINGID = A.MTSHARINGID)
    and not exists (select P.ID from PR_MODELTYPE_SHARING_COUNTRIES_EXCEPT_CUST P with (nolock) where P.MTSHARINGCOUNTRYID = B.ID and P.CUSTID = @customerid)
                
  if @settID is not null
    return 1  
    
  
  /* ПО заказчику, если определены модели */
  
  select @settID = A.MTSHARINGID
  from PR_MODELTYPE_SHARING_DEPS A with (nolock)
  left join PR_MODELTYPE_SHARING_CUSTOMERS B with (nolock) on B.MTSHARINGID = A.MTSHARINGID
  where A.DEPID in (select ID from @deps)
    and B.CUSTOMERID = @customerid
    and exists (select GG.ID from PR_MODELTYPE_SHARING_MODELS GG with (nolock) where GG.MTSHARINGID = A.MTSHARINGID and GG.MODELID = @modelid)
  
  if @settID is not null
    return 1                  

  /* ПО заказчику, если НЕ определены модели */
  
  select @settID = A.MTSHARINGID
  from PR_MODELTYPE_SHARING_DEPS A with (nolock)
  left join PR_MODELTYPE_SHARING_CUSTOMERS B with (nolock) on B.MTSHARINGID = A.MTSHARINGID
  where A.DEPID in (select ID from @deps)
    and B.CUSTOMERID = @customerid
    and not exists (select GG.ID from PR_MODELTYPE_SHARING_MODELS GG with (nolock) where GG.MTSHARINGID = A.MTSHARINGID)
  
  if @settID is not null
    return 1                  

  
  return 0;
end;