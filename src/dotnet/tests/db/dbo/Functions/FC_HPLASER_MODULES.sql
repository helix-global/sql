CREATE function [dbo].[FC_HPLASER_MODULES](@MTgid uniqueidentifier,@DeviceID int, @UserID int,@aMode int)
returns nvarchar(max)
as
begin

   if @MTgid <> '42b821d8-bc1e-4123-9cce-0210be2b72ad' /*HPLaser*/
      return null
      
   if dbo.DEF_USERINGROUP5(@UserID,'HPLview',null,null,null,null) <> 1
      return null

   declare @res nvarchar(max)
   set @res = ''
   
   select @res = @res + case when len(@res) > 0 then ', ' else '' end + ltrim(rtrim(A.SN)) 
   from PR_DEVICE_BOM A with (nolock)
   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
   left join PR_MODELTYPE C with (nolock) on C.ID = B.TYPEID
   where A.DEVICEID = @DeviceID
     and A.UNINSTALLOPERID is null 
     and C.GID = '8df4c0aa-00c1-4d57-adc1-71674032da02'  /*fiber module*/
       
       
   if LEN(@res) = 0
     return null
     
   return @res  

end;