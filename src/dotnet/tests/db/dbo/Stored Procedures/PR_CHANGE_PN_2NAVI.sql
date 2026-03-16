CREATE procedure [dbo].[PR_CHANGE_PN_2NAVI] @aMode int, @OperID int, @aUserID int, @aDate datetime
WITH EXECUTE AS OWNER , RECOMPILE
as 
SET nocount on

declare @emplN nvarchar(20)

select @emplN = isnull(ltrim(rtrim(str(B.PERSONALNO))),'NA')
from DEF_USERS A with (nolock) 
left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
where A.ID = @aUserID


if @aMode = 1  /* смена */
begin

	  insert into PDB_BUFFER..PN_CHANGES (S_S,S_CR,S_CDT,OLDPARTNUMBER,OUTDATE,SN,QUANTITY,PRODUCTIONORDER,EMPLOYEENUMBER,NEWPARTNUMBER,OPERATIONID,DEPID,LOCATION,MODE)
	  select 1000199, @aUserID, @aDate, MOLD.CODE, @aDate, D.SN, D.RESQUANTITY, O.NN, @emplN, MNEW.CODE, A.ID, O.DEPARTMENTID,  SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20) , 1
	  from PR_OPERATION A with (nolock)
	  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
	  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
	  left join COM_DEPARTMENTS DD with (nolock) on DD.ID = O.DEPARTMENTID
	  left join PR_MODELS MOLD with (nolock) on MOLD.ID = A.OLDMODELID
	  left join PR_MODELS MNEW with (nolock) on MNEW.ID = A.NEWMODELID
	  where A.ID = @OperID
		and A.NEWMODELID is not null
		and A.OLDMODELID is not null
		and A.NEWMODELID <> A.OLDMODELID


end
else if @aMode = 2  /* отмена */
begin

	  insert into PDB_BUFFER..PN_CHANGES (S_S,S_CR,S_CDT,OLDPARTNUMBER,OUTDATE,SN,QUANTITY,PRODUCTIONORDER,EMPLOYEENUMBER,NEWPARTNUMBER,OPERATIONID,DEPID,LOCATION,MODE)
	  select 1000199, @aUserID, @aDate, MNEW.CODE, @aDate, D.SN, D.RESQUANTITY, O.NN, @emplN, MOLD.CODE, A.ID, O.DEPARTMENTID,  SUBSTRING(isnull(DD.POSTINGCODE,DD.CODE),1,20) , 2
	  from PR_OPERATION A with (nolock)
	  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
	  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
	  left join COM_DEPARTMENTS DD with (nolock) on DD.ID = O.DEPARTMENTID
	  left join PR_MODELS MOLD with (nolock) on MOLD.ID = A.OLDMODELID
	  left join PR_MODELS MNEW with (nolock) on MNEW.ID = A.NEWMODELID
	  where A.ID = @OperID
		and A.NEWMODELID is not null
		and A.OLDMODELID is not null
		and A.NEWMODELID <> A.OLDMODELID

end

SET nocount off