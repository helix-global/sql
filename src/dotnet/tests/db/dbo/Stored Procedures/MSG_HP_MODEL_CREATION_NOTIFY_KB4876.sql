CREATE PROCEDURE [dbo].[MSG_HP_MODEL_CREATION_NOTIFY_KB4876] @aModelID int, @aUserID int, @aMode int
AS
BEGIN

	/* KB4876 20.08.2024 Create Efimov MV */
	/* send nitification to user from table, about creating new model in "HP Laser" model type */
	set nocount on

	declare @modelType int = 0
	declare @modelName nvarchar(250)
	declare @creatorName nvarchar(250)
	select 
		@modelType = M.TYPEID,
		@modelName = M.NAME,
		@creatorName = U.FULLNAME
	from dbo.PR_MODELS M with (nolock) 
	left join dbo.DEF_USERS U with (nolock) on M.S_CR = U.ID
	where M.ID = @aModelID

	if @modelType<>37 /* 'HP Laser' */
	begin
		set nocount off
		return
	end
	
	declare @subj nvarchar(250) = 'New "HP Laser" model created'

	declare @body nvarchar(max) =''
	set @body = 'Dear Collegue/s,<br/>'+
				'Following model was created in "HP Laser" model type:<br/><br/>' +
				'Model name : ' + @modelName + '<br/>' +
				'Created by: ' + @creatorName + '<br/>' +
				'<a href="a2l:\\Link=doc.pr_models.'+ CONVERT(nvarchar(50),@aModelID) + '">Link to PDB<a>' + '<br/><br/>' +
				'Please do not respond,<br/>Production Database'

    declare @toEmails nvarchar(max)
	select @toEmails = dbo.GROUP_CONCAT_D(isnull(E.EMAIL,''), ';')
	from MSG_HP_MDL_CR_NTF_RCPTS R with(nolock)
	left join COM_EMPLOYEE E with (nolock) on E.ID = R.EMPLID 

	if len(isnull(@toEmails,'')) < 2
	begin
		set nocount off
		return
	end

	EXEC MSG_SEND 26052, @toEmails, '', @subj, @body


	set nocount off
END


--a2l:\\Link=doc.pr_models.428510
--select * from dbo.PR_MODELS with (nolock) where ID > 428508
--select * from dbo.PR_MODELTYPE where ID = 37 /* 'HP Laser' */