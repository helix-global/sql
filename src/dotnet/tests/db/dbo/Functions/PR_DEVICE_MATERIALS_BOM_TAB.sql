CREATE function [dbo].[PR_DEVICE_MATERIALS_BOM_TAB] (@DeviceID int, @aMode int)
returns @res table (CODE nvarchar(50),NAME nvarchar(250),QTY decimal(18,6),SRC int,ONLYOPTION int,USEOPTQTY int, OPTQTY int, MID int, OPERID int)
as 
begin

    /* @aMode - reserved для ПЛАН/ФАКТ */
  
    declare @RevID int
    declare @MTypeID int
    declare @mapID int
  
    select @RevID = A.REVID
          ,@MTypeID = B.TYPEID
          ,@mapID = A.MAPID
    from PR_DEVICE A with (nolock)
    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
    where A.ID = @DeviceID

	insert into @res (SRC,CODE,NAME,QTY,ONLYOPTION,USEOPTQTY,MID,OPERID)
	select 1,BB.CODE,BB.NAME,AA.QUANTITY,AA.ONLYOPTION,AA.USEOPTQTY,BB.ID,AA.OPERID
	from PR_REV_PDMU AA with (nolock)
	left join PR_NAV_PN_CACHE BB with (nolock) on BB.ID = AA.MID
	where AA.REVID = @RevID
	  and AA.OPERID in (select K.OPERID from PR_MAP_OPER K with (nolock) where K.MAPID = @mapID)
	  and (AA.ONLYOPTION is null or AA.ONLYOPTION in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))
	  and (AA.WITHOUTOPTION is null or AA.WITHOUTOPTION not in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))
	order by AA.OPERID

    insert into @res (SRC,CODE,NAME,QTY,ONLYOPTION,USEOPTQTY,MID,OPERID)
    select 2,BB.CODE,BB.NAME,AA.QUANTITY,AA.ONLYOPTION,AA.USEOPTQTY,BB.ID,AA.OPERID
    from PR_MODELTYPE_PDMU AA with (nolock)
    left join PR_MODELTYPE_COMMON AAA with (nolock) on AAA.ID = AA.MTID
    left join PR_NAV_PN_CACHE BB with (nolock) on BB.ID = AA.MID
    where AAA.MTID = @MTypeID
      and AA.OPERID in (select K.OPERID from PR_MAP_OPER K with (nolock) where K.MAPID = @mapID)
      and (AA.ONLYOPTION is null or AA.ONLYOPTION in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))
      and (AA.WITHOUTOPTION is null or AA.WITHOUTOPTION not in (select O.OPTID from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID))
    order by AA.OPERID      
  
    update @res set OPTQTY = (select sum(O.QUANTITY) from PR_DEVICE_OPT O with (nolock) where O.DEVICEID = @DeviceID and O.OPTID = "@res".ONLYOPTION)
	where isnull(USEOPTQTY,0) = 1

	update @res set QTY = QTY * OPTQTY
	where isnull(USEOPTQTY,0) = 1
  
    return

end