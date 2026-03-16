CREATE procedure [dbo].[SW_CHECK_STORAGE_ITEM] @aID int, @aMode int, @aUserID int 
as 
set nocount on

declare @CheckID int
declare @PrtID int
declare @DepID int
declare @DepIDFromPrt int

select @CheckID = A.ID
  ,@DepID = A.DEPID
  ,@PrtID = B.ID
  ,@DepIDFromPrt = B.DEPID
from SW_STORAGE A 
left join SW_STORAGE B with (nolock) on B.ID = A.PARENTID 
where A.ID = @aID


if @CheckID is not null
begin
 
    if dbo.COM_DEP_ACCESS2(@DepID,1,@aUserID,getdate()) <> 1
    begin
		raiserror('#ECannot write changes to this department.',16,0)
		set nocount off
		return
    end
    
    if @PrtID is not null and @DepIDFromPrt is not null
    begin
		if dbo.COM_DEP_ACCESS2(@DepIDFromPrt,1,@aUserID,getdate()) <> 1
		begin
			raiserror('#ECannot write changes to this department.',16,0)
			set nocount off
			return
		end
    end
 

    /* проверка на кольцо PARENTID -> ID */
	declare @parentID int
	declare @i int = 0
    set @parentID = @aID
	while 1=1
	begin
	  select @parentID = isnull(A.PARENTID, 0) from SW_STORAGE A with (nolock) where ID = @parentID
	  
	  if @parentID = 0
		 break
	  
	  set @i = @i + 1
	  
	  if @i > 500
	  begin
		raiserror('#ECannot found root parent node in tree structure. Tree structure is wrong.',16,0)
		set nocount off
		return
	  end
	end
end


set nocount off