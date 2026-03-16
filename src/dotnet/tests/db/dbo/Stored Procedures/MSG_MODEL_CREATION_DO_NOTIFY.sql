CREATE PROCEDURE [dbo].[MSG_MODEL_CREATION_DO_NOTIFY] @aModelID int, @aUserID int, @aMode int
AS
BEGIN
	set nocount on
	
	declare @now datetime
	set @now = GETDATE()   

    declare @mtid int
    declare @code nvarchar(50)
    declare @name nvarchar(250)
    declare @mtName nvarchar(250)
    declare @depName nvarchar(250)
    declare @emplName nvarchar(250)
    declare @emplPhone nvarchar(250)
    declare @emplEmail nvarchar(250)
    
    select @mtid = A.TYPEID
          ,@code = A.CODE
          ,@name = A.NAME
          ,@mtName = B.NAME
          ,@depName = E.NAME
          ,@emplName = K.NAME
          ,@emplPhone = K.PHONE
          ,@emplEmail = K.EMAIL
    from PR_MODELS A with (nolock)
    left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID
    left join COM_DEPARTMENTS E with (nolock) on E.ID = A.DEPID
    left join DEF_USERS J with (nolock) on J.ID = A.S_CR
    left join COM_EMPLOYEE K with (nolock) on K.ID = J.EMPLOYEEID
    where A.ID = @aModelID

    
    if not exists (select D.ID from MSG_MODELS_CREA_NOTI_T D with (nolock) where D.MTID = @mtid)
    begin
      set nocount off
      return
    end


	declare @settID int
	declare @Subj nvarchar(1024)
	declare @msgTo nvarchar(1024)
	declare @msgCopyTo nvarchar(1024)
	
	declare nxx cursor local read_only for 
	select distinct A.VNESHID, B.CAPTION, B.MSGTO, B.MSGCOPYTO
    from MSG_MODELS_CREA_NOTI_T A with (nolock)
    left join MSG_MODELS_CREA_NOTI B with (nolock) on B.ID = A.VNESHID
    where A.MTID = @mtid
      and B.ENBL = 1
      
	open nxx 
	WHILE 1=1
	BEGIN
	    set @settID = null
	    set @Subj = null
	    set @msgTo = null
	    set @msgCopyTo = null
	
		FETCH NEXT FROM nxx INTO @settID, @Subj, @msgTo, @msgCopyTo ;
		IF @@FETCH_STATUS<>0 BREAK;

		declare @mess nvarchar(max)
		set @mess = 'Dear All,<br><br>The new model has been created in PDB models:<br>'
		set @mess = @mess + '<br>Navision Code: <b>' + isnull(@code,'NA') +'</b>' 
		set @mess = @mess + '<br>Name: <b>' + isnull(@name,'NA')  +'</b>' 
		set @mess = @mess + '<br>Model Type: <b>' + isnull(@mtName,'NA')  +'</b>' 
		set @mess = @mess + '<br>' 
		set @mess = @mess + '<br>Model Owner: ' + isnull(@depName,'NA')  
		set @mess = @mess + '<br>' 
		set @mess = @mess + '<br>Creator: ' + isnull(@emplName,'NA') + '<br>' + isnull(@emplPhone,'') + '<br>' + isnull(@emplEmail,'')

		set @mess = @mess + '<br><br>Please, do not answer this e-mail.<br>Production Database'

		exec MSG_SEND @aUserID,@msgTo,@msgCopyTo,@Subj,@mess
	    
	END
	close nxx;
	deallocate nxx;


	set nocount off
END