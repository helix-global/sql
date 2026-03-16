CREATE function [dbo].[PR_DEVICE_IN_SUBSCRIPTION](@aDeviceID int, @aMode int)
returns int
begin

/*
   @aMode - 1 - только approved подписки
            2 - любые
*/
  
declare @CustomerID int
declare @mtid int
declare @depid int
declare @modelid int
declare @SN nvarchar(50)
declare @PN nvarchar(150)

select @CustomerID = isnull(C.CUSTOMERID, B.CUSTOMERID)
      ,@mtid = M.TYPEID
      ,@depid = B.DEPARTMENTID
      ,@modelid = A.MODELID
      ,@SN = A.SN
      ,@PN = M.CODE
from PR_DEVICE A with (nolock)
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join PR_SUPPLY C with (nolock) on C.ID = A.SORDERID
where A.ID = @aDeviceID

if (@aMode = 1)
begin

   if exists (select A.ID from MSG_FILENOTIFICATIONS A with (nolock) 
        	   left join MSG_FILENOTIFICATIONS_CONTACTS X with (nolock) on X.VNESHID = A.ID
	           left join COM_CUST_CONTACTS C with (nolock) on C.ID = X.CONTACTID
              where A.MTID = @mtid
              and A.DEPID = @depid
              /*and A.CUSTOMERID = @CustomerID*/
              and C.CUSTOMERID = @CustomerID
              and (isnull(A.ALLMODELS,0) =1 or exists (select N.ID from MSG_FILENOTIFICATIONS_MODELS N with (nolock) where N.VNESHID = A.ID and N.MODELID = @modelid))
              and A.S_S = 1000176 /*approved*/
              )
      return 1
end
else if (@aMode = 2)
begin

   if exists (select A.ID from MSG_FILENOTIFICATIONS A with (nolock) 
        	   left join MSG_FILENOTIFICATIONS_CONTACTS X with (nolock) on X.VNESHID = A.ID
	           left join COM_CUST_CONTACTS C with (nolock) on C.ID = X.CONTACTID
              where A.MTID = @mtid
              and A.DEPID = @depid
              /*and A.CUSTOMERID = @CustomerID*/
              and C.CUSTOMERID = @CustomerID              
              and (isnull(A.ALLMODELS,0) =1 or exists (select N.ID from MSG_FILENOTIFICATIONS_MODELS N with (nolock) where N.VNESHID = A.ID and N.MODELID = @modelid))
              )
      return 1
end  
  
  
return 0
  
end