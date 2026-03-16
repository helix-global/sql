CREATE function [dbo].[PR_ACCESS_2SERVICE] (@aUserID int,@aMode int,@aDate datetime)
returns @res table (MODELID int, CUSTOMERID int)
as 
begin


  declare @deps table (ID int)
  insert into @deps (ID)
  select ID 
  from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 
  
  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select a.ID 
    from @deps d cross apply
        dbo.COM_GETCHILD_DEPARTMENTS2(d.ID,1) a

    declare @mtSharing table (ID int, MODELTYPEID int, HASCUSTOMERS int, HASMODELS int, HASCOUNTRIES int)

    insert into @mtSharing
    select S.ID, S.MODELTYPEID, 0, 0, 0 
        from PR_MODELTYPE_SHARING S

    update @mtSharing set HASCUSTOMERS=1
        from @mtSharing A
        where exists(select ID from PR_MODELTYPE_SHARING_CUSTOMERS where MTSHARINGID=A.ID)

    
    update @mtSharing set HASMODELS=1
        from @mtSharing A
        where exists(select ID from PR_MODELTYPE_SHARING_MODELS where MTSHARINGID=A.ID)

    
    update @mtSharing set HASCOUNTRIES=1
        from @mtSharing A
        where exists(select ID from PR_MODELTYPE_SHARING_COUNTRIES where MTSHARINGID=A.ID)
        

  insert into @res (MODELID, CUSTOMERID)
    select A.ID,null
          from PR_MODELS A with (nolock) 
            left join PR_MODELTYPE B on B.ID = A.TYPEID
          where (A.DEPID in (select ID from @deps) or B.DEPARTMENTID in (select ID from @deps))
    union
  select A.ID,null 
      from PR_MODELS A with (nolock) 
        left join PR_SERVICE_DEPARTMENTS B with (nolock) on B.MTID = A.TYPEID
      where B.DEPID in (select ID from @deps)
    union
    select SM.MODELID,null --нет ограничений по кастомеру и странам
        from PR_MODELTYPE_SHARING_MODELS SM with (nolock) 
            join @mtSharing S on SM.MTSHARINGID=S.ID
            join PR_MODELTYPE_SHARING_DEPS SD with (nolock)  on S.ID=SD.MTSHARINGID
        where S.HASCUSTOMERS=0 and S.HASCOUNTRIES=0 and S.HASMODELS=1 
            and SD.DEPID in (select ID from @childDeps) 
    union
    select M.ID, null
        from PR_MODELS M  with (nolock) 
            join @mtSharing S on M.TYPEID=S.MODELTYPEID         
            join PR_MODELTYPE_SHARING_DEPS  SD with (nolock) on S.ID=SD.MTSHARINGID
        where SD.DEPID in (select ID from @childDeps) 
            and S.HASCUSTOMERS=0 and S.HASCOUNTRIES=0 and S.HASMODELS=0
    union
    select SM.MODELID,SC.CUSTOMERID --ограничения по кастомеру
        from PR_MODELTYPE_SHARING_MODELS SM with (nolock)
            join @mtSharing S on SM.MTSHARINGID=S.ID
            join PR_MODELTYPE_SHARING_DEPS SD with (nolock) on S.ID=SD.MTSHARINGID
            join PR_MODELTYPE_SHARING_CUSTOMERS SC with (nolock) on S.ID=SC.MTSHARINGID
        where S.HASCUSTOMERS=1 and S.HASMODELS=1 
            and SD.DEPID in (select ID from @childDeps) 
    union 
    select M.ID, SC.CUSTOMERID 
        from PR_MODELS M with (nolock) 
            join @mtSharing S on M.TYPEID=S.MODELTYPEID         
            join PR_MODELTYPE_SHARING_DEPS SD with (nolock) on S.ID=SD.MTSHARINGID
            join PR_MODELTYPE_SHARING_CUSTOMERS SC with (nolock) on S.ID=SC.MTSHARINGID
        where SD.DEPID in (select ID from @childDeps) 
            and S.HASCUSTOMERS=1 and S.HASMODELS=0
    union
    select SM.MODELID,C.ID --ограничения по стране
        from PR_MODELTYPE_SHARING_MODELS SM with (nolock)
            join @mtSharing S on SM.MTSHARINGID=S.ID
            join PR_MODELTYPE_SHARING_DEPS SD with (nolock) on S.ID=SD.MTSHARINGID
            join PR_MODELTYPE_SHARING_COUNTRIES SC with (nolock) on SC.MTSHARINGID=S.ID
            join COM_CUSTOMER C with (nolock) on SC.COUNTRYID=C.COUNTRY
        where S.HASCOUNTRIES=1 and S.HASMODELS=1 
            and SD.DEPID in (select ID from @childDeps) 
    /*union 
    select M.ID, C.ID
        from PR_MODELS M with (nolock) 
            join @mtSharing S on M.TYPEID=S.MODELTYPEID         
            join PR_MODELTYPE_SHARING_DEPS SD with (nolock) on S.ID=SD.MTSHARINGID
            join PR_MODELTYPE_SHARING_COUNTRIES SC with (nolock) on SC.MTSHARINGID=S.ID
            join COM_CUSTOMER C with (nolock) on SC.COUNTRYID=C.COUNTRY
        where SD.DEPID in (select ID from @childDeps) 
            and S.HASCOUNTRIES=1 and S.HASMODELS=0*/
    except
    select M.ID,EC.CUSTID
      from PR_MODELTYPE_SHARING_DEPS SD with (nolock) 
          left join @mtSharing S on S.ID=SD.MTSHARINGID
          left join PR_MODELTYPE_SHARING_COUNTRIES SC with (nolock) on SC.MTSHARINGID=S.ID
          left join PR_MODELTYPE_SHARING_COUNTRIES_EXCEPT_CUST EC with (nolock) on SC.ID=EC.MTSHARINGCOUNTRYID
          left join PR_MODELS M with (nolock) on M.TYPEID=S.MODELTYPEID and EC.CUSTID is not null
      where SD.DEPID in (select ID from @childDeps) 


/*
  declare @deps table (ID int)
  insert into @deps (ID)
  select ID 
  from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,@aMode,@aDate) 
  
  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select a.ID 
    from @deps d cross apply
        dbo.COM_GETCHILD_DEPARTMENTS2(d.ID,1) a

  insert into @res (MODELID, CUSTOMERID)
  select A.ID,null
  from PR_MODELS A with (nolock) 
  left join PR_MODELTYPE B on B.ID = A.TYPEID
  where (A.DEPID in (select ID from @deps) or B.DEPARTMENTID in (select ID from @deps))
    union
  select A.ID,null 
  from PR_MODELS A with (nolock) 
  left join PR_SERVICE_DEPARTMENTS B with (nolock) on B.MTID = A.TYPEID
  where B.DEPID in (select ID from @deps)
    union
  select SM.MODELID,SC.CUSTOMERID
  from PR_MODELTYPE_SHARING_DEPS SD 
  left join PR_MODELTYPE_SHARING S on S.ID=SD.MTSHARINGID
  left join PR_MODELTYPE_SHARING_MODELS SM on SM.MTSHARINGID=S.ID
  left join PR_MODELTYPE_SHARING_CUSTOMERS SC on SC.MTSHARINGID=S.ID
  where SD.DEPID in (select ID from @childDeps)
    union
  select M.ID,SC.CUSTOMERID
  from PR_MODELTYPE_SHARING_DEPS SD 
  left join PR_MODELTYPE_SHARING S on S.ID=SD.MTSHARINGID
  left join PR_MODELTYPE_SHARING_MODELS SM on SM.MTSHARINGID=S.ID
  left join PR_MODELTYPE_SHARING_CUSTOMERS SC on SC.MTSHARINGID=S.ID
  left join PR_MODELS M with (nolock) on M.TYPEID=S.MODELTYPEID
  where SD.DEPID in (select ID from @childDeps)
    and SM.ID is null
*/
  return

end