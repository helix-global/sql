
CREATE PROCEDURE [dbo].[MSG_PLANED_DATE_CHANGED]
AS
BEGIN

    set nocount on
    
    if not exists (select ID from MSG_PLANNED_DATES_CHANGES)
    begin
      set nocount off
      return
    end
    
    delete from MSG_PLANNED_DATES_CHANGES 
    where exists (select B.ID from MSG_PLANNED_DATES_CHANGES B where B.DEVICEID = MSG_PLANNED_DATES_CHANGES.DEVICEID and B.ID > MSG_PLANNED_DATES_CHANGES.ID)

    declare @idstosend table (ID int not null,DEPID int not null,DEVICEID int not null,MESS nvarchar(max),DOLD datetime,DNEW datetime)
    insert into @idstosend (ID,DEPID,DEVICEID,DOLD,DNEW)
    select A.ID,C.DEPARTMENTID,A.DEVICEID,A.OLDDATE,A.NEWDATE
      from MSG_PLANNED_DATES_CHANGES A
      left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
      left join PR_PRORDER C with (nolock) on C.ID = B.ORDERID

    declare @msgs table (DEPID int)
    
    insert into @msgs (DEPID)
    select distinct A.DEPID from @idstosend A
    where exists (select G.ID from MSG_DELIVERYLIST G where G.DEPID = A.DEPID and G.DELIVERYTYPE = 1606)
    
    update @idstosend set MESS = dbo.MSG_PLANNEDDATECHANGE_TEXT(DEVICEID,DOLD,DNEW)
    
    
	declare @depid int
	declare nxx cursor local read_only for 
	select distinct DEPID from @msgs
	open nxx 
	WHILE 1=1
	BEGIN
	FETCH NEXT FROM nxx INTO @depid;
	IF @@FETCH_STATUS<>0 BREAK;

		declare @mess nvarchar(max)
		set @mess = 'Dear All,<br><br>The following planned dates was changed:<br><br><font size="-2"><table width="1000" cellspacing = "1" bgcolor="#eeeeee" border="1" bordercolor="#ffffff">'
		set @mess = @mess + '<tr><th>SN</th><th>Supply Order</th><th>Model</th><th>Customer</th><th>Previous Planed Date</th><th>New Planned Date</th><th>Readiness,%</th></tr>'

		select @mess = @mess + A.MESS
		from @idstosend A where A.DEPID = @depid

		set @mess = @mess + '</table></font><br><br>Please, do not answer this e-mail.<br>Production Database'

        /*KB2198*/
        if @depid = 151 /*ILA only*/
        begin
            declare @excludeDepIDs nvarchar(max) = null
			declare @hasCHP int = 0
			select @hasCHP = 1 where exists(
			   select A.ID 
			   from @idstosend A 
			   cross apply dbo.PR_DEVICE_BOM_MODELS(A.DEVICEID) B
			   left join PR_MODELS C with (nolock) on C.ID = B.PARTMODELID
			   left join PR_MODELTYPE D with (nolock) on D.ID = C.TYPEID
			   left join COM_DEPARTMENTS E with (nolock) on E.ID = D.DEPARTMENTID
			   where A.DEPID = @depid 
				and E.CODE = 'CHP'
			)
			if @hasCHP = 0
			  set @excludeDepIDs = '86'
			 
			exec MSG_PLANED_DATE_CHANGED_SEND 0,1606,@depid,'Planned date(s) was changed',@mess,@excludeDepIDs  
			  
		end	
		else
		begin

   		   exec MSG_SEND_TODELIVERYGROUP 0,1606,@depid,'Planned date(s) was changed',@mess 
   		   
   		end   

	END
	close nxx;
	deallocate nxx;    
	
	delete from MSG_PLANNED_DATES_CHANGES where ID in (select ID from @idstosend)
	
	set nocount off	
END