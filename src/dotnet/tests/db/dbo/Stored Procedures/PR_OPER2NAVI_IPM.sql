CREATE procedure [dbo].[PR_OPER2NAVI_IPM]
  @OperID  int
,@aUserID int
,@aDate   datetime
with execute as owner,
     recompile
as
  set nocount on

  declare @sn nvarchar(20)
  declare @ordn nvarchar(20)
  declare @ordn2 nvarchar(20)
  declare @emplN nvarchar(20)
  declare @devID int
  declare @depID int
  declare @mtID int
  declare @cou int
  declare @inventoryMode int
  declare @orderType int
  declare @serviceOrd nvarchar(20)
  declare @depCode nvarchar(20)

  select @sn = D.SN
        ,@ordn = O.NN
        ,@devID = A.DEVICEID
        ,@mtID = M.TYPEID
        ,@depID = O.DEPARTMENTID
        ,@inventoryMode = isnull(MM.INVENTORYMODE, 0)
        ,@orderType = O.ORDERTYPE
        ,@depCode = substring(isnull(DD.POSTINGCODE, DD.CODE), 1, 20)
  from PR_OPERATION A with (nolock)
  left join PR_DEVICE D with (nolock) on D.ID = A.DEVICEID
  left join PR_PRORDER O with (nolock) on O.ID = A.ORDERID
  left join PR_MODELS M with (nolock) on M.ID = D.MODELID
  left join PR_NAV_DEPMODES MM with (nolock) on MM.DEPID = O.DEPARTMENTID
  left join COM_DEPARTMENTS DD with (nolock) on DD.ID = O.DEPARTMENTID
  where A.ID = @OperID

  select @emplN = isnull(rtrim(ltrim(cast(B.PERSONALNO as nvarchar(20)))), 'NA')
  from DEF_USERS A with (nolock)
  left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLOYEEID
  where A.ID = @aUserID

  insert into PR_NAVIOUT (OPERID, PARTNUMBER, PARTSN, QUANTITY, VERS, BOMID, BATCHN)
  select @OperID
        ,dbo.PR_NAV_PN_REPLACE(B.CODE, B.REPLACEX)
        ,A.SN
        ,isnull(A.PARTQUANTITY, 1)
        ,2
        ,A.BOMID
        ,A.BATCHN
  from PR_OPERATION_INSTALL A
  left join PR_MODELS B with (nolock) on B.ID = A.PARTMODELID
  where A.OPERID = @OperID
  and B.CODE is not null

  insert into PR_NAVIOUT (OPERID, PARTNUMBER, PARTSN, QUANTITY, VERS, BOMID, UNITEMSTAT, REPAIRABLE, BATCHN)
  select @OperID
        ,dbo.PR_NAV_PN_REPLACE(B.CODE, B.REPLACEX)
        ,I.SN
        ,-isnull(I.PARTQUANTITY, 1)
        ,2
        ,I.BOMID
        ,A.UNITEMSTAT
        ,C.REPAIRABLE
       ,I.BATCHN
  from PR_OPERATION_UNINSTALL A
  left join PR_OPERATION_INSTALL I on I.ID = A.INSTALLROWID
  left join PR_MODELS B on B.ID = I.PARTMODELID
  left join PR_MODELTYPE C on C.ID = B.TYPEID
  where A.OPERID = @OperID
  and B.CODE is not null


  insert into PR_NAVIOUT (OPERID, PARTNUMBER, PARTSN, QUANTITY, VERS, BATCHN, ASDEFECTIVE)
  select @OperID
        ,A.CODE
        ,'-987'
        ,case when isnull(B.MAT_USAGE_X_QTY, 0) = 1 then A.QUANTITY
              when isnull(A.QTYPEROPERATION,0) = 1 then A.QUANTITY 
              else A.QUANTITY * isnull(B.PREP_RESULT, 1)
         end
        ,2
        ,A.BATCHN
        ,case when A.ASDEFECTIVE = 1 then 1 end
  from PR_OPERATION_MU A
  left join PR_OPERATION B on B.ID = A.OPERID
  where A.OPERID = @OperID
  and A.QUANTITY is not null

  set @ordn = ltrim(@ordn)
  set @serviceOrd = null
  /*set @ordn2 = SUBSTRING(@ordn,1,10)*/
  set @ordn2 = @ordn /*  IPM! */

  if @orderType = 1 /*service*/
  begin

    if substring(upper(@ordn), 1, 3) <> 'MOF'
    begin
      set @serviceOrd = @ordn
      set @ordn2 = null
    end

  end

  insert into PDB_BUFFER..MATERIALS (S_S, S_CR, S_CDT, PARTNUMBER, OUTDATE, SN, QUANTITY, PRODUCTIONORDER, SERVICEORDER, EMPLOYEENUMBER, PARTSN, OPERATIONID, DEPID, LOCATION, FAILED, BATCHNUMBER)
  select 1
        ,@aUserID
        ,@aDate
        ,PARTNUMBER
        ,@aDate
        ,upper(@sn)
        ,case
           when REPAIRABLE = 0 and S3 = 1 and DELTA = -1 then 0
           else DELTA
         end /*если неремонтопригодный и дефектный, то ноль */
        ,@ordn2
        ,@serviceOrd
        ,@emplN
        ,PARTSN
        ,@OperID
        ,@depID
        ,upper(@depCode)
        ,case when ASDEFECTIVE = 1 then 1 else S3 end
        ,BATCHN
  from (
    select PARTNUMBER
          ,nullif(PARTSN, '-987') as PARTSN
          ,isnull(S2, 0) - isnull(S1, 0) as DELTA
          ,case S3
             when 1 then 1
             else 0
           end as S3
          ,isnull(REPAIRABLE, 0) as REPAIRABLE
          ,substring(BATCHN, 1, 20) as BATCHN
          ,ASDEFECTIVE
    from (
      select PARTNUMBER
            ,PARTSN
            ,BATCHN
            ,ASDEFECTIVE
            ,(
               select sum(B1.QUANTITY)
               from PR_NAVIOUT B1
               where B1.OPERID = @OperID
               and B1.PARTNUMBER = A.PARTNUMBER
               and B1.PARTSN = A.PARTSN
               and isnull(B1.BATCHN, '') = isnull(A.BATCHN, '')
               and isnull(B1.ASDEFECTIVE,0) = isnull(A.ASDEFECTIVE,0)
               and B1.VERS = 1
             ) as S1
            ,(
               select sum(B1.QUANTITY)
               from PR_NAVIOUT B1
               where B1.OPERID = @OperID
               and B1.PARTNUMBER = A.PARTNUMBER
               and B1.PARTSN = A.PARTSN
               and isnull(B1.BATCHN, '') = isnull(A.BATCHN, '')
               and isnull(B1.ASDEFECTIVE,0) = isnull(A.ASDEFECTIVE,0)
               and B1.VERS = 2
             ) as S2
            ,(
               select max(isnull(B3.UNITEMSTAT, 0))
               from PR_NAVIOUT B3
               where B3.OPERID = @OperID
               and B3.PARTNUMBER = A.PARTNUMBER
               and B3.PARTSN = A.PARTSN
               and isnull(B3.BATCHN, '') = isnull(A.BATCHN, '')
               and isnull(B3.ASDEFECTIVE,0) = isnull(A.ASDEFECTIVE,0)
               and B3.VERS = 2
             ) as S3
            ,(
               select max(isnull(B4.REPAIRABLE, 0))
               from PR_NAVIOUT B4
               where B4.OPERID = @OperID
               and B4.PARTNUMBER = A.PARTNUMBER
               and B4.PARTSN = A.PARTSN
               and isnull(B4.BATCHN, '') = isnull(A.BATCHN, '')
               and isnull(B4.ASDEFECTIVE,0) = isnull(A.ASDEFECTIVE,0)
               and B4.VERS = 2
             ) as REPAIRABLE

      from (
        select distinct PARTNUMBER
                       ,PARTSN
                       ,BATCHN
                       ,ASDEFECTIVE
        from PR_NAVIOUT
        where OPERID = @OperID
      ) A
    ) M
    where isnull(S1, 0) != isnull(S2, 0)
  ) M2


  delete from PR_NAVIOUT
  where OPERID = @OperID
    and VERS = 1

  update PR_NAVIOUT
  set VERS = 1
  where OPERID = @OperID

  declare @newSS int
  set @newSS = 1000044

  if @inventoryMode = 1
    set @newSS = 1000068

  update PDB_BUFFER..MATERIALS
  set S_S = @newSS
  where OPERATIONID = @OperID
    and S_S = 1

  set nocount off