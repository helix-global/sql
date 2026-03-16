create function [dbo].[PR_IS_OPER_POSTED2NAVI_test](@OperID int, @OnDate datetime)
returns int as 
begin

declare @DepID int
declare @ModelID int
declare @DeviceID int
declare @OrdID int
declare @OrdNN nvarchar(20)
declare @DevSN nvarchar(50)
declare @MTID int
declare @OrderType int

select 
    @DepID = O.DEPARTMENTID
   ,@ModelID = A.MODELID
   ,@DeviceID = D.DEVICEID
   ,@OrdID = D.ORDERID
   ,@OrdNN = O.NN
   ,@DevSN = A.SN
   ,@MTID = M.TYPEID
   ,@OrderType = ISNULL(O.ORDERTYPE,0)
from PR_OPERATION D with (nolock) 
left join PR_DEVICE A with (nolock) on A.ID = D.DEVICEID
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_PRORDER O with (nolock) on O.ID = D.ORDERID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where D.ID = @OperID


if @DeviceID is null /*preparation*/
  return 0
  
if @DevSN like 'SN not assigned%'
  return 0

if UPPER(@OrdNN) like '%TEST%'
  return 0
  

declare @m2Mat int 
declare @m2Time int 
declare @m2Device int
declare @m2ServMat int
declare @m2ServTime int

declare @ddate datetime
set @ddate = CAST(@OnDate as date)



declare @SettingID int

select top 1 @SettingID = A.ID 
from PR_NAV_DEPMODES A with (nolock) 
where A.DEPID = @DepID 
  and A.MTID = @MTID
  and exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID and B.MODELID = @ModelID)

if @SettingID is null
begin
	select top 1 @SettingID = A.ID 
	from PR_NAV_DEPMODES A with (nolock) 
	where A.DEPID = @DepID 
	  and A.MTID = @MTID
	  and not exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID)
end

if @SettingID is null
begin
	select top 1 @SettingID = A.ID 
	from PR_NAV_DEPMODES A with (nolock) 
	where A.DEPID = @DepID 
	  and A.MTID is null
	  and not exists (select B.ID from PR_NAV_DEPMODES_T B with (nolock) where B.VNESHID = A.ID)
end

if @SettingID is null
   return 0 

select  
  @m2Mat = case when A.M2_MAT <= @ddate then 1 else 0 end
, @m2Time = case when A.M2_TIME <= @ddate then 1 else 0 end
, @m2Device = case when A.M2_DEV <= @ddate then 1 else 0 end
, @m2ServMat = case when A.S2_MAT <= @ddate then 1 else 0 end
, @m2ServTime = case when A.S2_TIME <= @ddate then 1 else 0 end
from PR_NAV_DEPMODES A with (nolock) 
where A.ID = @SettingID

/*
select top 1 
  @m2Mat = case when A.M2_MAT <= @ddate then 1 else 0 end
, @m2Time = case when A.M2_TIME <= @ddate then 1 else 0 end
, @m2Device = case when A.M2_DEV <= @ddate then 1 else 0 end
, @m2ServMat = case when A.S2_MAT <= @ddate then 1 else 0 end
, @m2ServTime = case when A.S2_TIME <= @ddate then 1 else 0 end
from PR_NAV_DEPMODES A with (nolock) 
where A.DEPID = @DepID 
  and (A.MTID is null or A.MTID = @MTID)
  */

if (@m2Mat = 1 and @m2Time = 1) 
  return 1
  
if (@m2Device = 1) 
  return 2

if (@m2Time = 1)
  return 44 
 
if @OrderType = 1
begin
   if @m2ServMat = 1 and @m2ServTime = 1
      return 100
   if @m2ServMat = 1 
      return 66 
end

if (@m2Mat = 1) 
  return 3


return 0

end