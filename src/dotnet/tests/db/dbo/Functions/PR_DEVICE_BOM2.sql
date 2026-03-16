
CREATE function [dbo].[PR_DEVICE_BOM2](@DeviceId int)
returns @result table
      (
        ID              int
       ,DEVICEID           int
       ,BOMID           int
       ,PARTID          int
       ,OPERATIONID     int
       ,COMPLETED_DT    datetime
       ,OPERTYPEID      int
       ,SN              nvarchar(50)
       ,PARTID_OL       nvarchar(50)
       ,MODELID         int
       ,REMARK          nvarchar(250)
       ,MODELNAME       nvarchar(200)
       ,PARTQUANTITY    decimal(20,10)
       ,UNINSTALLOPERID int
      )
as
  begin

    insert into @result (ID, DEVICEID, BOMID, PARTID, OPERATIONID, COMPLETED_DT, OPERTYPEID, SN, PARTID_OL, MODELID, REMARK, MODELNAME, PARTQUANTITY, UNINSTALLOPERID)
    select C.ID
          ,@DeviceId
          ,C.BOMID
          ,C.PARTID
          ,B.ID as OPERATIONID
          ,B.COMPLETED_DT
          ,B.OPERTYPEID
          ,C.SN
          ,C.SN as PARTID_OL
          ,FF.ID as MODELID
          ,C.REMARK
          ,FF.NAME as MODELNAME
          ,isnull(C.PARTQUANTITY, 1) as PARTQUANTITY
          ,(
             select top (1) II.OPERID
             from dbo.PR_OPERATION_UNINSTALL as II
             left outer join dbo.PR_OPERATION as IIO on IIO.ID = II.OPERID
             where (II.INSTALLROWID = C.ID)
             and (IIO.S_S in (1000013, 1000019))
           ) as UNINSTALLOPERID
    from dbo.PR_DEVICE as A
    left outer join dbo.PR_OPERATION as B on B.DEVICEID = A.ID
    left outer join dbo.PR_OPERATION_INSTALL as C on C.OPERID = B.ID
    left outer join dbo.PR_MODELS as FF on FF.ID = C.PARTMODELID
    where (C.ID is not null)
    and (B.S_S in (1000013, 1000019, 1000038, 1000116))
    and (C.PARTID is not null)
    and A.ID=@DeviceId
    
    insert into @result (ID, DEVICEID, BOMID, PARTID, OPERATIONID, COMPLETED_DT, OPERTYPEID, SN, PARTID_OL, MODELID, REMARK, MODELNAME, PARTQUANTITY, UNINSTALLOPERID)
    select C.ID
          ,@DeviceId
          ,C.BOMID
          ,C.PARTID
          ,B.ID as OPERATIONID
          ,B.COMPLETED_DT
          ,B.OPERTYPEID
          ,C.SN
          ,C.SN as PARTID_OL
          ,FF.ID as MODELID
          ,C.REMARK
          ,FF.NAME as MODELNAME
          ,isnull(C.PARTQUANTITY, 1) as PARTQUANTITY
          ,(
             select top (1) II.OPERID
             from dbo.PR_OPERATION_UNINSTALL as II
             left outer join dbo.PR_OPERATION as IIO on IIO.ID = II.OPERID
             where (II.INSTALLROWID = C.ID)
             and (IIO.S_S in (1000013, 1000019))
           ) as UNINSTALLOPERID
    from dbo.PR_DEVICE as A
    left outer join dbo.PR_OPERATION as B on B.DEVICEID = A.ID
    left outer join dbo.PR_OPERATION_INSTALL as C on C.OPERID = B.ID
    left outer join dbo.PR_MODELS as FF on FF.ID = C.PARTMODELID
    where (C.ID is not null)
    and (B.S_S in (1000013, 1000019, 1000038, 1000116))
    and (C.PARTID is not null)
    and B.ID in (select N.OPERID from PR_PARENT_OPERATION N with (nolock) where N.DEVICEID = @DeviceID and isnull(N.DONTUSEPARAMETERS,0) <> 1)
  
  return

  end;