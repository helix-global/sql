CREATE function [dbo].[PR_DEVICE_FIND_PART] (@DeviceID int, @BomID int, @aSN nvarchar(50))
returns @res table (PARTID int,PARTMODELID int,PARTONLYREVID int,FINDEDCOUNT int)
as 
begin

   insert into @res (PARTMODELID,PARTONLYREVID)
   select A.PARTMODELID,A.PARTONLYREVID 
     from dbo.PR_DEVICE_BOM_MODELS(@DeviceID) A
    where A.BOMID = @BomID
    
   update @res set PARTID = (select A.ID 
                               from PR_DEVICE A 
                              where A.MODELID = "@res".PARTMODELID 
                                and A.SN = @aSN                               
                             )

   declare @finded int
   select @finded = COUNT(*) from @res where PARTID is not null
   
   if @finded = 1
     delete from @res where PARTID is null
   
   update @res set FINDEDCOUNT = @finded

   return

end