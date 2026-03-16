create function [dbo].[WEB_GET_OPER_COMPONENTS](@UserID int, @aOperID int)
returns @res table (ID int, PN nvarchar(16), SN nvarchar(50), QTY decimal(20,10), BOMNAME nvarchar(100), PARTID int, PARTMODELID int )
as 
begin

  insert into @res (ID,PN,SN,QTY,BOMNAME,PARTID,PARTMODELID)
  select A.ID,C.CODE,A.SN,isnull(A.PARTQUANTITY,1),B.NAME,A.PARTID,A.PARTMODELID
  from PR_OPERATION_INSTALL A with (nolock)
  left join PR_MODELTYPE_BOM B with (nolock) on B.ID = A.BOMID
  left join PR_MODELS C with (nolock) on C.ID = A.PARTMODELID
  where A.OPERID = @aOperID


return

end