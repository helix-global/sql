-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[COM_TRAINING_TRAINERS]
(
	@trainingID int
)
RETURNS nvarchar(max)
AS
BEGIN

	declare @ret nvarchar(max)
	set @ret=''

	if @trainingID is not null
	begin
		select @ret=  @ret + E.NAME + ','
		from COM_TRAINING_OPERATIONS O
			join COM_EMPLOYEE E on O.TRAINER_ID=E.ID
		where O.TRAININGID=@trainingID
		group by E.NAME
	end

	if @ret<>''
		set @ret = SUBSTRING(@ret,1,len(@ret)-1)

	return @ret

END