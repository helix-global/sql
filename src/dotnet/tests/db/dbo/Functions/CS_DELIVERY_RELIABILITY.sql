CREATE function [dbo].[CS_DELIVERY_RELIABILITY](@mtID int, @UserID int, @dbeg datetime, @dend datetime)
returns @res table (DD date, V_PLUS int,V_MINUS int)
begin
  
  /* KB2100 */
  declare @MTdepID int
  select @MTdepID = A.DEPARTMENTID from PR_MODELTYPE A with (nolock) where A.ID = @mtID
   
  
  declare @tmp table (DEVICEID int,SO_ID int, CDD date, SHREQID int, SHDD date)
  
  insert into @tmp (DEVICEID,SO_ID,CDD,SHREQID)
  select A.ID
  ,C.ID
  ,C.CDD
  ,(select top 1 KK.ID 
      from SH_ORDER_T K with (nolock)
      left join SH_ORDER KK with (nolock) on KK.ID = K.SHORDERID 
     where K.DEVICEID = A.ID 
       and KK.S_S in (1000024/*shipped*/)
     order by KK.ID) 
  from PR_DEVICE A with (nolock)
  left join PR_MODELS B with (nolock) on B.ID = A.MODELID
  left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
  where B.TYPEID = @mtID 
    and B.DEPID = @MTdepID
    and C.CDD >= @dbeg
    and C.CDD < @dend
    
  update @tmp set SHDD = (select D.DD from SH_ORDER D with (nolock) where D.ID = "@tmp".SHREQID)  
 
  declare @tmp2 table (SO_ID int, CDD date, V_PLUS int, V_MINUS int)
  
  insert into @tmp2 (SO_ID,CDD)
  select distinct SO_ID,CDD from @tmp where SHREQID is not null
 
  update @tmp2 set V_PLUS = (select count(distinct A.SHREQID) from @tmp A where A.SO_ID = "@tmp2".SO_ID and A.SHDD <= "@tmp2".CDD) 
   
  update @tmp2 set V_MINUS = (select count(distinct A.SHREQID) from @tmp A where A.SO_ID = "@tmp2".SO_ID and A.SHDD > "@tmp2".CDD) 
 
  
  insert into @res(DD,V_PLUS,V_MINUS)
  select CDD,sum(V_PLUS),sum(V_MINUS)
  from @tmp2
  group by CDD 

  return

end