CREATE procedure [dbo].[PR_IMP_ROLLBACK_PACKET]
  @ContextID int, @UserID int
as 
set nocount on


delete from PR_DEVICE_IN_VALUES where PACKETID = @ContextID
delete from PR_OPERATION_FILES where OPERATIONID in (select ID 
                                                  from PR_OPERATION 
												 where DEVICEID in (select B.DEVICEID 
												                     from PR_IMP_PACKET_T B 
																 where B.VNESHID = @ContextID) 
												   and IMPID = @ContextID)
delete from PR_OPERATION where DEVICEID in (select B.DEVICEID from PR_IMP_PACKET_T B where B.VNESHID = @ContextID) and IMPID = @ContextID
delete from PR_IMP_PACKET_T where VNESHID = @ContextID



set nocount off