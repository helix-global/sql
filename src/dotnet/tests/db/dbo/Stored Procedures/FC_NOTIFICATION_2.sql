CREATE PROCEDURE [dbo].[FC_NOTIFICATION_2]
AS
BEGIN

  declare @now datetime
  declare @notDate datetime
  declare @dayOfWeek int
  set @now = GETDATE()
  
  if datepart(hour,@now) < 8 return
  if datepart(hour,@now) > 13 return

  set @now = CAST (@now as date)
  set @dayOfWeek = (@@datefirst+datepart(weekday,@now)-2)%7+1; 
    
  declare @needDeliveryTypes table (DTYPE int)
  
  /* 1347 check */
  select @notDate = CAST (NOTIFDD as date) from FC_NOTIFICATIONS A with (nolock) where A.NOTIFTYPE = 1347
  if isnull(@notDate,'20000101') < @now and dbo.COM_IS_WORKDAY(@now,1) = 1
  begin
     update FC_NOTIFICATIONS set NOTIFDD = @now where NOTIFTYPE = 1347
     if @@ROWCOUNT = 0
        insert into FC_NOTIFICATIONS (NOTIFTYPE,NOTIFDD) values (1347,@now)
     insert into @needDeliveryTypes(DTYPE) values (1347)
  end  

  /* 1444 check */
  
  if @dayOfWeek = 5
  begin
      select @notDate = null
	  select @notDate = CAST (NOTIFDD as date) from FC_NOTIFICATIONS A with (nolock) where A.NOTIFTYPE = 1444
	  if isnull(@notDate,'20000101') < @now 
	  begin
		 update FC_NOTIFICATIONS set NOTIFDD = @now where NOTIFTYPE = 1444
		 if @@ROWCOUNT = 0
			insert into FC_NOTIFICATIONS (NOTIFTYPE,NOTIFDD) values (1444,@now)
		 insert into @needDeliveryTypes(DTYPE) values (1444)
	  end  
  end

  declare @deliveryid int,@deliverytype int
  declare nxx cursor local read_only for 
  select distinct A.VNESHID, B.DELIVERYTYPE
    from MSG_DELIVERYLIST_T A with (nolock) 
    left join MSG_DELIVERYLIST B with (nolock) on B.ID = A.VNESHID
   where B.DELIVERYTYPE in (select G.DTYPE from @needDeliveryTypes G)
  open nxx 
  WHILE 1=1
  BEGIN
 	FETCH NEXT FROM nxx INTO @deliveryid, @deliverytype;
	IF @@FETCH_STATUS<>0 BREAK;
	exec FC_NOTIFICATION_2ONE @deliveryid, @deliverytype;
  END
  close nxx;
  deallocate nxx;  

END