
create procedure TRB_REQUESTS_CHANGES_ADD(@RequestID int, @FieldName nvarchar(50), @OldValue nvarchar(4000), @NewValue nvarchar(4000), @UserID int)
AS
BEGIN

/* KB4439 Добавление изменений в booking request */


declare @state int = 5130009 /* Sended to driver */
declare @now datetime = getdate()

	insert into dbo.TRB_REQUESTS_CHANGES 
	(VNESHID, FIELDNAME, OLDVALUE, NEWVALUE, AUTHORID, GID, S_S, S_CR, S_CDT)
	values 
	(@RequestID, @FieldName, @OldValue, @NewValue, @UserID, newid(), @state , @UserID, @now)
		
END