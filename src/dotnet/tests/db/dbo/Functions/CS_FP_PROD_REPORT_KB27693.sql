create function [dbo].[CS_FP_PROD_REPORT_KB27693](@aUserID int, @modelGroupID int, @dBeg datetime, @dEnd datetime, @revIds nvarchar(MAX))
returns @res table (YYYY int, PROD_QTY decimal(18,2), GOOD_QTY decimal(18,2), BAD_QTY decimal(18,2), UNDEF_QTY decimal(18,2))
as 
begin

  declare @dateparamID int, @stockparamID int, @posparamID int
  declare @mtid int

  declare @revisions table (ID int)

  insert into @revisions
  select ID
	from dbo.COM_STR2TABLE_INT(@revIds)
  
  select top 1 @dateparamID = A.ID 
             , @mtid = B.ID
    from PR_MODELTYPE_PARAMS A with (nolock)
    left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
   where A.NAME = 'Ziehdatum'
     and B.GID = '728620C4-3B04-4537-96FA-AD5DC711FEEC'  /*Fibers*/
     
     
  select top 1 @stockparamID = A.ID from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @mtid and A.NAME = 'stock'
  
  select top 1 @posparamID = A.ID from PR_MODELTYPE_PARAMS A with (nolock) 
  where A.TYPEID = @mtid and A.NAME = 'general position'
  
/* по маске YYMMDD-#-#-# */
  declare @items3dies table (ID int not null, YYYY int, RESQTY int) 
  
  insert into @items3dies (ID, YYYY, RESQTY )
  select ID, year(DD), isnull(RESQUANTITY,1)
  from (
  select C.ID 
        ,dbo.PR_DEVICE_PARAM_DATE(C.ID, @dateparamID) as DD
        ,C.RESQUANTITY
  from PR_DEVICE C with (nolock)
  left join PR_MODELS D with (nolock) on D.ID = C.MODELID
  left join PR_REVISION E with (nolock) on E.ID = C.REVID
  where D.TYPEID = @mtid
    and isnull(E.MODELGROUPID, D.MODELGROUPID) = @modelGroupID
    and C.S_S not in (1000101/*canceled*/,1000029/*pend.prod*/,1000008/*in prod*/,1000069,1000100/*postponed*/,1)
    and C.SN like '______-%-%-%'
    and len(C.SN) - len(replace(C.SN,'-','')) = 3 
	and E.ID in (select ID from @revisions)
  ) M  
  where DD >= @dBeg
    and DD <= @dEnd

/* по маске YYMMDD-#-#-#-# */     
  declare @items4dies  table (ID int not null, YYYY int, RESQTY int, S_S int, PRM_stock sql_variant, PRM_general_position sql_variant) 
  
  insert into @items4dies (ID, YYYY, RESQTY, S_S, PRM_stock, PRM_general_position)
  select ID, year(DD), isnull(RESQUANTITY,1),  S_S
       ,dbo.PR_DEVICE_PARAM(ID, @stockparamID)
       ,dbo.PR_DEVICE_PARAM(ID, @posparamID)
  from (
  select C.ID 
        ,C.S_S 
        ,dbo.PR_DEVICE_PARAM_DATE(C.ID, @dateparamID) as DD
        ,C.RESQUANTITY
  from PR_DEVICE C with (nolock)
  left join PR_MODELS D with (nolock) on D.ID = C.MODELID
  left join PR_REVISION E with (nolock) on E.ID = C.REVID
  where D.TYPEID = @mtid
    and isnull(E.MODELGROUPID, D.MODELGROUPID) = @modelGroupID
    and C.SN like '______-%-%-%-%'
    and len(C.SN) - len(replace(C.SN,'-','')) = 4 
	and E.ID in (select ID from @revisions)
  ) M  
  where DD >= @dBeg
    and DD <= @dEnd
    
    
    
  /*
  ,1000078/*failed*/,1000158/*recycled*/
  */
  
  insert into @res (YYYY)
  select distinct YYYY
  from @items3dies
  union 
  select distinct YYYY
  from @items4dies
  
  
  update @res set PROD_QTY = (select sum(B.RESQTY) from @items3dies B where B.YYYY = "@res".YYYY) 
  
  update @res set GOOD_QTY = (select sum(B.RESQTY) 
                               from @items4dies B 
                              where B.YYYY = "@res".YYYY 
                                and (S_S not in (1, 1000101/*canceled*/, 1000029/*pending prod*/,1000008/*in prod*/, 1000069,1000100/*postpo*/,1000078/*failed*/,1000158/*recycled*/) 
                                      and isnull(PRM_stock,'') <> 'failed tests_'
                                      and isnull(PRM_general_position,'') <> 'terminieren_'
                                     ) 
                              ) 

  update @res set BAD_QTY = (select sum(B.RESQTY) 
                               from @items4dies B 
                              where B.YYYY = "@res".YYYY 
                                and (S_S in (1000078/*failed*/,1000158/*recycled*/) 
                                      or PRM_stock = 'failed tests_'
                                      or PRM_general_position = 'terminieren_'
                                     ) 
                              ) 

  update @res set UNDEF_QTY = (select sum(B.RESQTY) 
                               from @items4dies B 
                              where B.YYYY = "@res".YYYY 
                                and (S_S not in (1000101/*canceled*/, 1000029/*pending prod*/) 
                                      and (PRM_general_position = 'measurement_'
                                           or PRM_general_position = 'Production test_' 
                                           )                                     
                                     ) 
                              ) 

  if @aUserID = 3
  begin
    update @res set PROD_QTY = isnull(GOOD_QTY,0) + isnull(BAD_QTY,0) + isnull(UNDEF_QTY,0)
  end

  return 
 
end