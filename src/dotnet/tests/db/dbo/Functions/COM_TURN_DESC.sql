CREATE function [dbo].[COM_TURN_DESC](@aEmplID int, @aDT datetime)
returns nvarchar(max) as 
begin
  
   declare @res nvarchar(max)
   declare @baseDate date = cast(@aDT as date)  
   declare @wtID int
   
   select @wtID = ISNULL(A.PERSONALWT,B.ID)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID = @aEmplID
   
   if @wtID is null
     return null /* если график не указан */
     
   declare @wturn int
   select @wturn = A.WTURN from COM_TURNS A where A.EMPLID = @aEmplID and A.DD = @baseDate
   set @wturn = ISNULL(@wturn,1)
   
   declare @TurnBeg time 
   declare @TurnEnd time 
   declare @TurnEndNextDay int = 0
   
   select @TurnBeg = min(cast(A.TFROM as time))
     from COM_WORKTIME_BR A with (nolock) 
    where A.VNESHID = @wtID 
      and A.WTURN = @wturn 

   select @TurnEnd = max(cast(A.TTO as time))
     from COM_WORKTIME_BR A with (nolock) 
    where A.VNESHID = @wtID 
      and A.WTURN = @wturn 
      and cast(A.TFROM as time) < cast(A.TTO as time)
      
   if exists (select A.ID from COM_WORKTIME_BR A with (nolock) 
                where A.VNESHID = @wtID 
                  and A.WTURN = @wturn 
                  and cast(A.TFROM as time) > cast(A.TTO as time)
                  and dbo.COM_IS_WORK_NIGHT(@aDT,cast(A.TFROM as time),cast(A.TTO as time)) = 1) 
      begin
        set @TurnEndNextDay = 1
		select @TurnEnd = max(cast(A.TTO as time))
		 from COM_WORKTIME_BR A with (nolock) 
		where A.VNESHID = @wtID 
		  and A.WTURN = @wturn 
		  and cast(A.TFROM as time) > cast(A.TTO as time)
      end
      
   declare @calcD datetime = cast(@aDT as date)
   declare @calcDateB datetime = @calcD + cast(@TurnBeg as datetime)
   declare @calcDateE datetime = @calcD + cast(@TurnEnd as datetime)
   if @TurnEndNextDay = 1
     set @calcDateE = dateadd(day,1,@calcDateE)
       
   declare @middle int = (datediff(mi,@calcD,@calcDateB) + datediff(mi,@calcD,@calcDateE)) / 2
   set @res = 'From '+convert(nvarchar,@calcDateB,121)+' To '+convert(nvarchar,@calcDateE,121)+' (Work Table ID = '+ltrim(str(@wtID))+' )'
   return @res
  
end