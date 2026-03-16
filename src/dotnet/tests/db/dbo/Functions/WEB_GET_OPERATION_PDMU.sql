CREATE function [dbo].[WEB_GET_OPERATION_PDMU](@UserID int, @OperID int)
returns @res table (SRC int, CODE nvarchar(50), QTY decimal(18,6),NOADDQUANTITY int, ONLYOPTION int, ONLYOPTIONCODE nvarchar(50), USEOPTQTY int, OPTQTY int, QTYPEROPERATION int) 
as 
begin

declare @RevID int
declare @OperTypeID int
declare @DeviceID int  
declare @OrderID int  
declare @MTypeID int
declare @OpersCount int /*определение "повторности" операции*/

select @RevID = B.REVID
    ,@OperTypeID = A.OPERTYPEID
	,@DeviceID = A.DEVICEID
	,@OrderID = A.ORDERID
	,@MTypeID = C.TYPEID
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_MODELS C with (nolock) on C.ID = B.MODELID
where A.ID = @OperID

select @OpersCount = count(*) 
from PR_OPERATION A with (nolock) 
where A.DEVICEID = @DeviceID
and A.ORDERID = @OrderID
and A.OPERTYPEID = @OperTypeID
and A.ID <> @OperID

insert into @res (SRC,CODE,QTY,NOADDQUANTITY,ONLYOPTION,USEOPTQTY,QTYPEROPERATION)
select 1,BB.CODE,AA.QUANTITY,AA.NOADDQUANTITY,AA.ONLYOPTION,AA.USEOPTQTY,isnull(AA.QTYPEROPERATION,0)
from PR_REV_PDMU AA with (nolock)
left join PR_NAV_PN_CACHE BB with (nolock) on BB.ID = AA.MID
where AA.REVID = @RevID
  and AA.OPERID = @OperTypeID
  and (@OpersCount = 0 or AA.USEINREPEATED = 1)
  and (AA.ONLYOPTION is null or AA.ONLYOPTION in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))

insert into @res (SRC,CODE,QTY,NOADDQUANTITY,ONLYOPTION,USEOPTQTY,QTYPEROPERATION)
select 2,BB.CODE,AA.QUANTITY,AA.NOADDQUANTITY,AA.ONLYOPTION,AA.USEOPTQTY,isnull(AA.QTYPEROPERATION,0)
from PR_MODELTYPE_PDMU AA with (nolock)
left join PR_MODELTYPE_COMMON AAA with (nolock) on AAA.ID = AA.MTID
left join PR_NAV_PN_CACHE BB with (nolock) on BB.ID = AA.MID
where AAA.MTID = @MTypeID
  and AA.OPERID = @OperTypeID
  and (@OpersCount = 0 or AA.USEINREPEATED = 1)
  and (AA.ONLYOPTION is null or AA.ONLYOPTION in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))


update @res set OPTQTY = (select sum(O.QUANTITY) from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID and O.OPTID = "@res".ONLYOPTION)
where isnull(USEOPTQTY,0) = 1

update @res set QTY = QTY * OPTQTY
where isnull(USEOPTQTY,0) = 1

update @res set ONLYOPTIONCODE = (select O.CODE from PR_MODELTYPE_OPTIONS O with (nolock) where O.ID = "@res".ONLYOPTION)

return

end