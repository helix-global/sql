CREATE function [dbo].[PR_DEVICE_STAT_DEC](@DeviceID int, @OrderID int, @aMode int, @now datetime)
returns decimal(12,2)
as
begin
  /*
    @aMode 
    1 - sum elapsed
    2 - sum waited (все время от создания операции до ее завершения) для вывода простоя нужно отнимать elapsed
    3 - время от запуска изделия до его завершения
    4 - sum duration (без распределения)
    5 - время между запуском изделия и началом первой операции по нему
    6 - время между началом первой операции по изделию и завершением
    7 - 1 если были ошибочные операции
    8 - число замененных компонент (снятых в replacement)
    9 - sum elapsed по ремонтным операциям
    10 - TODO sum specified man-hour
    11 - sum elapsed без ремонтных операций
    16 - время между началом первой операции по изделию и завершением (как 6, но по незавершенным до @now)
	20 - сумма времени по столобцу MANHOUR по всем опреациям (для KB4563) 

  */
   declare @res decimal(14,2)
   declare @res2 decimal(14,2)
   declare @dbeg datetime
   declare @dend datetime
   
   
   if @aMode = 1
   begin
     
     select @res = SUM(coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED)) 
     from PR_OPERATION_TIME A with (nolock) 
     left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
     where B.DEVICEID = @DeviceID 
       and B.ORDERID = @OrderID
       and isnull(B.TC_ACTION,0) <> 1 /* не учитывать всю операцию, имеющее переопределенное время */
   
     select @res2 = SUM(isnull(A.TC_MINUTE,0)) 
     from PR_OPERATION A with (nolock) 
     where A.DEVICEID = @DeviceID 
       and A.ORDERID = @OrderID
       and isnull(A.TC_ACTION,0) <> 0 /* суммируется со временем с операции */
   
     return isnull(@res,0) + isnull(@res2,0)
     
   end
   else if @aMode = 11
   begin
     
     select @res = SUM(coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED)) 
     from PR_OPERATION_TIME A with (nolock) 
     left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
     where B.DEVICEID = @DeviceID 
       and B.ORDERID = @OrderID
       and isnull(B.TC_ACTION,0) <> 1 /* не учитывать всю операцию, имеющее переопределенное время */
       and B.PARENTID is null
       and B.S_S not in (1000023,1000038)/*canceled,failure processed*/
   
     select @res2 = SUM(isnull(A.TC_MINUTE,0)) 
     from PR_OPERATION A with (nolock) 
     where A.DEVICEID = @DeviceID 
       and A.ORDERID = @OrderID
       and isnull(A.TC_ACTION,0) <> 0 /* суммируется со временем с операции */
       and A.PARENTID is null
       and A.S_S not in (1000023,1000038)/*canceled,failure processed*/
   
     return isnull(@res,0) + isnull(@res2,0)
     
   end
   else if @aMode = 2
   begin
   
     select @res = SUM(datediff(s,A.S_CDT,A.COMPLETED_DT)) from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID and A.COMPLETED_DT is not null
     return @res / 60
   
   end   
   else if @aMode = 3
   begin
  
      select @dbeg = min(A.S_CDT) from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID
      select @dend = A.COMPLETED_DT from PR_DEVICE A with (nolock) where A.ID = @DeviceID

      set @res = datediff(minute,@dbeg,@dend)

      if (abs(@res) < 2000000000 / 60)
      begin
         set @res = datediff(second,@dbeg,@dend)
         set @res = @res / 60
      end

      if (@res < 0)
        set @res = 0
        
      return @res
      
   end
   else if @aMode = 4
   begin
   
     select @res = SUM(datediff(s,A.DBEG,A.DEND))
     from PR_OPERATION_TIME A with (nolock) where A.OPERID in (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID)
     return @res / 60
   
   end   
   else if @aMode = 5
   begin   
 
      select @dbeg = min(A.S_CDT) from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID
      select @dend = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID in (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID)
      
      return datediff(minute,@dbeg,@dend)

   end
   else if @aMode = 6
   begin   
 
      select @dbeg = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID in (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID)
      select @dend = A.COMPLETED_DT from PR_DEVICE A with (nolock) where A.ID = @DeviceID
      
      set @res = datediff(minute,@dbeg,@dend)
       
      if (abs(@res) < 2000000000 / 60)
      begin
         set @res = datediff(second,@dbeg,@dend)
         set @res = @res / 60
      end
           
      if (@res < 0)
        set @res = 0
        
      return @res  

   end
   else if @aMode = 16
   begin   
 
      select @dbeg = min(A.DBEG) from PR_OPERATION_TIME A with (nolock) where A.OPERID in (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID)
      select @dend = isnull(A.COMPLETED_DT,@now) from PR_DEVICE A with (nolock) where A.ID = @DeviceID
      
      set @res = datediff(minute,@dbeg,@dend)
      if (@res < 0)
        set @res = 0
       
      return @res  

   end
   else if @aMode = 7
   begin   
      
      if exists (select A.ID from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID and A.S_S in (1000018,1000038/*failure,failure processed*/))
        return 1 
      
   end
   else if @aMode = 8
   begin   
      
      select @res = count(*) from PR_OPERATION_UNINSTALL B with (nolock) where B.OPERID in (select A.ID from PR_OPERATION A with (nolock) where A.DEVICEID = @DeviceID and A.ORDERID = @OrderID )
      return @res 
      
   end
   else if @aMode = 9
   begin   
      
     select @res = SUM(coalesce(A.ELAPSEDCORR,A.ELAPSED_D,A.ELAPSED)) 
     from PR_OPERATION_TIME A with (nolock) 
     where A.OPERID in (select B.ID 
                          from PR_OPERATION B with (nolock) 
                         where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID and (B.PARENTID is not null or B.S_S in (1000023,1000038)/*canceled,failure processed*/))
     return @res     
      
   end
   if @aMode = 20  /* for KB4563 */
   begin

	 --select @res = SUM(isnull(B.MANHOUR,0)) 
	 --    from PR_OPERATION B with (nolock)
     --where B.DEVICEID = @DeviceID 
     --  and B.ORDERID = @OrderID
     
	--select @res=sum(S.MANHOUR)
	--from 
	--	PR_OPERATION O 
	--left join PR_OPERATIONS S on S.ID = O.OPERTYPEID 
	--where O.ID in (select ID from dbo.PR_DEVICES_OPERATIONS(convert(varchar(50),@DeviceID)))

	select @res = sum(isnull(B.MANHOUR,isnull(A.MANHOUR,0)))
	from PR_OPERATION B 
	left join PR_OPERATIONS A on B.OPERTYPEID = A.ID
	where B.DEVICEID = @DeviceID and B.ORDERID = @OrderID

    return isnull(@res,0)
     
   end

  
   return null
end;