CREATE function [dbo].[PR_ITEM_HASCOMPONENTS](@aItemID int, @aCompModels nvarchar(max), @aMode int)
returns int
as
begin
/*
сделано под использование в KB3835
выдает 1 если в изделии @aItemID есть компоненты моделей @aCompModels
@aMode = 2  - ищет рекурсивно во всех дочерних компонентах (и это скорее всего медленно)
*/

    
  declare @t table (ID int)
  insert into @t
  select ID from dbo.COM_STR2TABLE_INT(@aCompModels)
  
  declare @comps table(PARTID int, MODELID int)
  
  insert into @comps (PARTID, MODELID)
  select A.PARTID, A.MODELID
    from PR_DEVICE_BOM A with(nolock) 
   where A.DEVICEID = @aItemID
  
  if exists (select A.* 
               from @comps A
              where A.MODELID in (select ID from @t))
  begin
	return 1
  end       
  
  if @aMode = 2
  begin
  
  
	declare @i int = 1
	while @i < 50
	begin

	  insert into @comps (PARTID, MODELID)
	  select A.PARTID, A.MODELID
		from PR_DEVICE_BOM A with(nolock) 
	   where A.DEVICEID in (select PARTID from @comps)
	     and not exists (select B.PARTID from @comps B where B.PARTID = A.PARTID)
       
      if @@rowcount = 0 break
       
	  if exists (select A.* 
				   from @comps A
				  where A.MODELID in (select ID from @t))
	  begin
		return 1
	  end       
       

      set @i = @i + 1    	   
	   
	end
     
  end                        
   
  return 0
end;