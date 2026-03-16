CREATE PROCEDURE [dbo].[MSG_APPROVAL_DO_NOTIFY] @aUserID int, @aNtype int, @aDocID int, @aMode int
AS
BEGIN
	set nocount on
/*
KB1389

рассылка при утверждении

@aNtype:
2101  -  модель
2102  -  ревизия
2103  -  форма
2104  -  карта
2105  -  отчет 

*/
   
	
	declare @now datetime
	set @now = GETDATE()   

	declare @Subj nvarchar(1024)
	declare @mess nvarchar(max)	
    declare @foundID int = null
    declare @depID int = null

	set @mess = 'Dear All,<br><br>'
		
	if 	@aNtype = 2101
	begin

       set @Subj = 'Model has been approved'
	   set @mess = @mess + @Subj + '<br>'
	   select @foundID = A.ID
	    ,@depID = A.DEPID
	    ,@mess = @mess + '<br>Code: '+A.CODE+'<br>Name: '+A.NAME+'<br>Model Type: '+T.NAME
	   from PR_MODELS A with (nolock)
	   left join PR_MODELTYPE T with (nolock) on T.ID = A.TYPEID
	   where A.ID = @aDocID
	
	
	end
	else if @aNtype = 2102
	begin

       set @Subj = 'Revision has been approved'
	   set @mess = @mess + @Subj + '<br>'
	   select @foundID = A.ID
	   ,@depID = B.DEPID
	   ,@mess = @mess +'<br>Model: '+B.NAME+'<br>Model Code: '+B.CODE+'<br>Model Type: '+T.NAME+'<br>Revision Name: '+A.NAME
	   from PR_REVISION A with (nolock)
	   left join PR_MODELS B with (nolock) on B.ID = A.MODELID
	   left join PR_MODELTYPE T with (nolock) on T.ID = B.TYPEID
	   where A.ID = @aDocID
	
	end
	else if @aNtype = 2103
	begin

       set @Subj = 'Operation form has been approved'
	   set @mess = @mess + @Subj + '<br>'
	   select @foundID = A.ID
	   ,@depID = A.DEPID
	   ,@mess = @mess +'<br>Name: '+A.NAME+'<br>ISO Number: '+A.CODE+'<br>Revision #: '+isnull(cast(A.REVN as nvarchar(14)),'NA')+'<br>Model Type: '+T.NAME
	   from PR_OPERATIONS A with (nolock)
	   left join PR_MODELTYPE T with (nolock) on T.ID = A.MTID
	   where A.ID = @aDocID
	
	end
	else if @aNtype = 2104
	begin

       set @Subj = 'Production/service map has been approved'
	   set @mess = @mess + @Subj + '<br>'
	   select @foundID = A.ID
	   ,@depID = A.DEPID
	   ,@mess = @mess +'<br>Name: '+A.NAME+'<br>ISO Number: '+isnull(A.NN,'NA')+'<br>Model Type: '+T.NAME
	   from PR_MAP A with (nolock)
	   left join PR_MODELTYPE T with (nolock) on T.ID = A.MTID
	   where A.ID = @aDocID
	
	end
	else if @aNtype = 2105
	begin

       set @Subj = 'Report template has been approved'
	   set @mess = @mess + @Subj + '<br>'
	   select @foundID = A.ID
	   ,@depID = A.DEPID
	   ,@mess = @mess +'<br>Name: '+A.NAME+'<br>ISO Number: '+A.CODE+'<br>Revision #: '+isnull(cast(A.REVN as nvarchar(14)),'NA')+'<br>Model Type: '+T.NAME
	   from PR_REPORTS A with (nolock)
	   left join PR_MODELTYPE T with (nolock) on T.ID = A.MTID
	   where A.ID = @aDocID
	
	end
	
	
	if @foundID is null or @depID is null or @Subj is null
	begin
	   set nocount off
	   return
	end
	
	
	declare @emplName nvarchar(250)
    declare @emplPhone nvarchar(250)
    declare @emplEmail nvarchar(250)
    
    select @emplName = K.NAME
          ,@emplPhone = K.PHONE
          ,@emplEmail = K.EMAIL
    from DEF_USERS J with (nolock) 
    left join COM_EMPLOYEE K with (nolock) on K.ID = J.EMPLOYEEID
    where J.ID = @aUserID
		
	if @emplPhone is not null
	  set @emplPhone = 'Phone: '+@emplPhone	
		
    set @mess = @mess + '<br><br>Approved by: ' + isnull(@emplName,'NA') + '<br>' + isnull(@emplPhone,'') + '<br>' + isnull(@emplEmail,'')
	set @mess = @mess + '<br><br>Please, do not answer this e-mail.<br>Production Database'

	/*print @mess*/
    exec MSG_SEND_TODELIVERYGROUP @aUserID, @aNtype, @depID, @Subj, @mess

	set nocount off
END