create function [dbo].[FC_HPLASER_COMP_SRV_NUMS](@MTgid uniqueidentifier,@DeviceID int, @UserID int,@aMode int)
returns nvarchar(max)
as
begin

   if @MTgid <> '42b821d8-bc1e-4123-9cce-0210be2b72ad' /*HPLaser*/
      return null
      
   if dbo.DEF_USERINGROUP5(@UserID,'HPLview',null,null,null,null) <> 1
      return null

   declare @res nvarchar(max)
   set @res = ''
   
   select @res = @res + case when len(@res) > 0 then ', ' else '' end + dbo.FC_REPORT_NUMBER2(D.RMA_TYPE,D.RMA) 
   from PR_DEVICE_BOM A with (nolock)
   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
   left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
   left join FC_REPORT D with (nolock) on D.DEVICEID = A.PARTID
   where A.DEVICEID = @DeviceID
     and A.UNINSTALLOPERID is null 
     and D.RMA is not null
       
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;