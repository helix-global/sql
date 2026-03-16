CREATE PROCEDURE [dbo].[MSG_SEND_FAR_METHOD] 
  @aUserID int, @aFarID int, @aMethodOID int, @aMethodComment nvarchar(max)
AS
BEGIN
  
    declare @DeliveryType int = 0
    declare @DepID int
    declare @sFRnumb nvarchar(300)
    declare @sFRnumb2 nvarchar(300)
    declare @sSubj nvarchar(300)
    declare @sBody nvarchar(max)
    declare @mImportance int
  
    if @aMethodOID in (1000132,1000133) /*approve,reject*/
       set @DeliveryType = 1501

    if @aMethodOID in (1000103) /*Analyzed*/
       set @DeliveryType = 1333

  
    if @DeliveryType > 0
    begin
    
		select @sFRnumb = 'FR-'+C.CODE+'-'+ltrim(rtrim(str(A.ID)))
		      ,@sFRnumb2 = dbo.FC_REPORT_NUMBER(A.RMA_TYPE,A.RMA)
			  /*,@DepID = B.DEPID  20.11.2018  KB279 */
			  ,@DepID = J.DEPARTMENTID
		from FC_REPORT A with (nolock)
		left join PR_MODELS B  with (nolock) on B.ID = A.MODELID
		left join PR_MODELTYPE J  with (nolock) on J.ID = B.TYPEID 
		left join COM_DEPARTMENTS C  with (nolock) on C.ID = B.DEPID
		where A.ID = @aFarID
		
		if len(@sFRnumb2) > 0
		  set @sFRnumb = @sFRnumb+', '+@sFRnumb2

		set @sBody = 'Dear All,<br><br>The failure report <a href = "a2l:\\Link=doc.fc_report.'+LTRIM(rtrim(str(@aFarID)))+'">'+@sFRnumb+'<a>'
		
		if @aMethodOID = 1000132
		begin
		    set @sSubj = @sFRnumb + ' approved'
		    set @sBody = @sBody + ' was approved.'
		end    
		else if @aMethodOID = 1000133
		begin
		    set @sSubj = @sFRnumb + ' rejected'
		    set @sBody = @sBody + ' was rejected.'
		    set @mImportance = 1
		    if @aMethodComment is not null
		       set @sBody = @sBody + '<br><br>' + @aMethodComment
	    end
	    else if @aMethodOID = 1000103
	    begin
		    set @sSubj = @sFRnumb + ' analyzed'
		    set @sBody = @sBody + ' was analyzed.'
		    set @sBody = @sBody + '<br><br>' + dbo.MSG_FAR_HTMLINFO(@aFarID,0)
	    end
		set @sBody = @sBody +'<br><br>Please, do not answer this e-mail.<br>Production Database'	  
	  
        exec MSG_SEND_TODELIVERYGROUP2 @aUserID, @DeliveryType, @DepID, @sSubj, @sBody, @mImportance
   
    end

END