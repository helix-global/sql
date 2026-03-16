
CREATE PROCEDURE COM_IMP_RECOMMEND_SEND_NOTIFICATION
(@impRecId int, @UserID int)
AS
BEGIN
	declare @state int, @subj nvarchar(1024), @body nvarchar(max), @num nvarchar(20), @toEMail nvarchar(150), @commentSPV nvarchar(500), @commentPLM nvarchar(500)

	select @state=R.S_S, @num=R.INITIATIVE_NUM, @toEMail=E.EMAIL, @commentSPV=R.SPV_COMMENT, @commentPLM=R.PLM_COMMENT
		from COM_IMP_RECOMMENDATIONS R 
				join COM_EMPLOYEE E on R.INITIATOR=E.ID
			where R.ID=@impRecId

	if @toEMail is null
		return
	
	if @state=4130002
	begin
		set @subj = 'Improvement Recommendation ' + @num + ' rejected by Supervisor'
		set @body = 'Improvement Recommendation <a href = ' + 
			'"a2l:\\Link=doc.com_improvement_recommendation.'+LTRIM(rtrim(str(@impRecId)))+'">' + @num + '<a> Rejected by Supervisor'  + char(13) + char(10) +
				'Comment: ' + @commentSPV
	end

	if @state=4130007
	begin
		set @subj = 'Improvement Recommendation ' + @num + ' rejected by Product Line Manager'
		set @body = 'Improvement Recommendation <a href = ' + 
			'"a2l:\\Link=doc.com_improvement_recommendation.'+LTRIM(rtrim(str(@impRecId)))+'">' + @num + '<a> Rejected by Product Line Manager'   + char(13) + char(10) +
				'Comment: ' + @commentPLM
	end

	if @state=4130003
	begin
		set @subj = 'Improvement Recommendation ' + @num + ' approved by Product Line Manager'
		set @body = 'Improvement Recommendation <a href = ' + 
			'"a2l:\\Link=doc.com_improvement_recommendation.'+LTRIM(rtrim(str(@impRecId)))+'">' + @num + '<a> Rejected by Product Line Manager'  + char(13) + char(10) +
				'Comment: ' + @commentPLM
	end
	
	if @subj is null 
		return

	exec MSG_SEND @UserID, @toEMail, null, @subj, @body

END