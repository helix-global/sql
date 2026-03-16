CREATE procedure [dbo].[PR_IMP_CMP_AND_DELETE_DUPL_VALUE_PACKET]  @PacketID int
as 
set nocount on

declare @ids table (ID int)

insert into @ids (ID)
select top 5000 A.ID from PR_DEVICE_IN_VALUES A with(nolock) where A.PACKETID = @PacketID

	declare @rID int
	declare cur cursor local read_only for 
    select ID from @ids 
    open cur
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM cur INTO @rID;
        IF @@FETCH_STATUS<>0 BREAK;
        
        exec PR_IMP_CMP_AND_DELETE_DUPL_VALUE @rID
        
    END
    close cur;
    deallocate cur;


set nocount off