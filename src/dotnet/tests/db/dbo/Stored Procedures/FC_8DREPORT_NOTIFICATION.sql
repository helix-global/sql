

CREATE PROCEDURE [dbo].[FC_8DREPORT_NOTIFICATION]
    @repId int, @UserID int
AS
BEGIN
    declare @nn nvarchar(50), @dep nvarchar(250), @txt varchar(max) = '', @subj nvarchar(1024), @teamLeaderId int

    select @nn=R.NN, @dep=R.DEPARTMENT, @teamLeaderId=dbo.COM_USER_BY_EMPL(R.TEAMLEADER)
        from FC_8D_REPORT R
        where ID=@repId
        
    set @subj = '8D Report Approval required (' + @nn + ')'

    set @txt = 'Dear All,<br><br>'
    
    set @txt = @txt + 'The 8D Report <a href = "a2l:\\Link=doc.fc_8d_report.'+LTRIM(rtrim(str(@repId)))+'">' + @nn + '</a> was analyzed in ' + isnull(@dep, '<N/A>') + ' department.<br><br>'
    
    set @txt = @txt + 'Please, do not answer this e-mail.<br>'
    set @txt = @txt + 'Production Database'

    exec dbo.MSG_SEND_TOUSER @UserID, @teamLeaderId, @subj, @txt
END