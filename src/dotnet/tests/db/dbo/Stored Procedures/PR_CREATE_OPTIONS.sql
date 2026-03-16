CREATE procedure [dbo].[PR_CREATE_OPTIONS] 
 @PrOrderID int, @UserID int
as 

SET nocount on

insert into PR_DEVICE_OPT (S_CR,S_CDT,GID,DEVICEID,OPTID,BOMID,OPTSN,QUANTITY)
select @UserID,getdate(),newid(),A.ID,B.OPTID,B.BOMID,dbo.PR_OPT_SN(S.SNMASK,A.SN),B.QTY
from PR_DEVICE A
cross apply dbo.PR_OPTIONS_BY_ORDERROW(A.ORDERROWID) B
left join PR_MODELTYPE_OPTIONS S on S.ID = B.OPTID
where A.ORDERID = @PrOrderID 
  and B.OPTID is not null

insert into PR_DEVICE_OPT (S_CR,S_CDT,GID,DEVICEID,OPTID,OPTSN,QUANTITY)
select @UserID,getdate(),newid(),A.ID,B.OPTIONID,dbo.PR_OPT_SN(S.SNMASK,A.SN),1
from PR_DEVICE A
left join PR_MODEL_OPTIONS B on B.MODELID = A.MODELID
left join PR_MODELTYPE_OPTIONS S on S.ID = B.OPTIONID
where A.ORDERID = @PrOrderID 
  and isnull(B.PREDEFINEDOPT,0) = 1
  and not exists (select G.ID from PR_DEVICE_OPT G where G.DEVICEID = A.ID and G.OPTID = B.OPTIONID)
  
/*15.05.15 по списку клиентов с опции */

insert into PR_DEVICE_OPT (S_CR,S_CDT,GID,DEVICEID,OPTID,OPTSN,QUANTITY)
select @UserID,getdate(),newid(),A.ID,B.OPTIONID,dbo.PR_OPT_SN(S.SNMASK,A.SN),1
from PR_DEVICE A
left join PR_MODEL_OPTIONS B on B.MODELID = A.MODELID
left join PR_MODELTYPE_OPTIONS S on S.ID = B.OPTIONID
left join PR_PRORDER O on O.ID = A.ORDERID
where A.ORDERID = @PrOrderID 
  and S.PREDEFINED_CUSTGRID is not null
  and exists (select G.ID from COM_CUST_GROUP_T G where G.VNESHID = S.PREDEFINED_CUSTGRID and G.CUSTID = O.CUSTOMERID)
  and not exists (select G.ID from PR_DEVICE_OPT G where G.DEVICEID = A.ID and G.OPTID = B.OPTIONID)

  
SET nocount off