CREATE function [dbo].[COM_TURN_TIME_DESC](@aEmplID int, @aDT datetime)
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
   select @wturn = A.WTURN from COM_TURNS A with(nolock) where A.EMPLID = @aEmplID and A.DD = @baseDate
   set @wturn = ISNULL(@wturn,1)
   
   declare @TurnBeg time 
   declare @TurnEnd time 
   
   select @TurnBeg = min(cast(cast(TFROM as time) as datetime) + adddaybeg)
     from (select A.TFROM
           /*,case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 else 0 end as adddaybeg*/
           , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 when isnull(A.TDEXTDAY,0) = 2 then -1 else 0 end as adddaybeg
		 from COM_WORKTIME_BR A with (nolock) 
		where A.VNESHID = @wtID 
		  and A.WTURN = @wturn 
		  )M

   select @TurnEnd = max(cast(cast(TTO as time) as datetime) + addday)
     from (select A.TTO
        /*,case when cast(A.TTO as time) < cast(A.TFROM as time) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday   */
        , case when (cast(A.TTO as time) < cast(A.TFROM as time) and isnull(A.TDEXTDAY,0) <> 2) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
		from COM_WORKTIME_BR A with (nolock) 
		where A.VNESHID = @wtID 
	 	  and A.WTURN = @wturn 
	 )M	
      

   set @res = dbo.COM_HHMM(@TurnBeg)+' - '+dbo.COM_HHMM(@TurnEnd)
   return @res
  
end