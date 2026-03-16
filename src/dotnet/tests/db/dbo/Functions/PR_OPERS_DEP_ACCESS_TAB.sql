CREATE function [dbo].[PR_OPERS_DEP_ACCESS_TAB](@aMode int,@aUser int,@aDate datetime)
returns @res table (ID int) as
begin
  
  declare @deps table (ID int)
  insert into @deps (ID)
  select A.ID from COM_DEPARTMENTS A with (nolock)
  where dbo.COM_DEP_ACCESS(null,A.ID,@aMode,@aUser,@aDate) = 1
    
  --добавляются настройки MT Sharing для дочерних отделов
  declare @childDeps table (ID int)
  insert into @childDeps(ID)
  select a.ID 
    from @deps d cross apply
        dbo.COM_GETCHILD_DEPARTMENTS2(d.ID,1) a

  insert into @res (ID)
  select A.ID
  from PR_OPERATIONS A with (nolock) 
  left join PR_OPERATIONS_GR B with (nolock) on B.ID = A.OPERGRID
  left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
  where B.DEPARTMENTID in (select ID from @deps)
     or C.DEPARTMENTID in (select ID from @deps)
     or A.DEPID in (select ID from @deps)
     
  /*KB667 добавлены сервисные операции от полученного/чужого типа моделей*/   
  insert into @res (ID)
  select A.ID
  from PR_OPERATIONS A with (nolock)    
  left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
  where exists (select M.ID from PR_MODELS M with (nolock) where M.TYPEID = A.MTID and M.DEPID in (select ID from @deps))
    and A.OPERTYPE > 1
    and A.SYNC2REMOTELOCATIONS = 1
    and A.DEPID not in (select ID from @deps)
    and C.DEPARTMENTID not in (select ID from @deps)
    
  if @aMode = 8
  begin
    
    if dbo.DEF_USERINGROUP4(@aUser,'DES',@aDate) = 1
    begin
        insert into @res (ID)
        select A.OPERID 
        from PR_MAP_OPER A with (nolock) 
        where A.MAPID in (select B.MAPID from PR_REVISION B with (nolock) 
                           where B.MODELID in (select C.MODELID from PR_MODEL_SHARINGR C with (nolock) 
                                                where C.DEPARTMENTID in (select ID from @deps)
                                                  and C.RULETYPE in (2,3)
                                              )
                         )                         
    end
  
    insert into @res (ID)
    select A.ID
    from PR_OPERATIONS A with (nolock) 
    left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
    where dbo.DEF_F_ACCESS2(C.ARC,null,2000017/*designer*/,@aDate,@aUser,0) = 1

    /*05.04.2019 добавлены операции для сервисных подразделений если есть разрешение в PR_EMPL_TO_OPERGR*/
    declare @emplID int
    select @emplID = B.EMPLOYEEID
    from DEF_USERS B with (nolock)
    where B.ID = @aUser    
    
    insert into @res (ID)
    select A.ID
    from PR_OPERATIONS A with (nolock) 
    left join PR_OPERATIONS_GR B with (nolock) on B.ID = A.OPERGRID
    left join PR_MODELTYPE C with (nolock) on C.ID = A.MTID
    left join PR_MODELTYPE_SHARING S with (nolock) on A.MTID=S.MODELTYPEID
    left join PR_MODELTYPE_SHARING_DEPS D with (nolock) on S.ID=D.MTSHARINGID 
    --left join PR_SERVICE_DEPARTMENTS F with (nolock) on F.MTID = A.MTID /*изменено на новую настройку*/
    where D.DEPID in (select ID from @childDeps)
      and exists (select K.ID from PR_EMPL_TO_OPERGR K with (nolock) 
                   where K.EMPLOYEEID = @emplID 
                     and K.ORDTYPE = 2 
                     and K.GROUPID = A.OPERGRID 
                     and K.DEPID in (select ID from @deps))

  
  end      
    
  return 
end