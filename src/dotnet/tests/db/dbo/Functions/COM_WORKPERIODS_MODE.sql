CREATE function [dbo].[COM_WORKPERIODS_MODE] (@dBeg datetime, @dEnd datetime, @calendar int, @whID int, @emplID int, @mode int, @DepID int)
RETURNS @res TABLE (DBEG datetime, DEND datetime)
AS
BEGIN

/*
сделана на основе COM_WORKPERIODS под KB4814 
при @mode = 22 и отделу FP к сменам добавляет "possible" смены
*/

    declare @isFP int = 0
    
    declare @possibleTurns table (DD date, WTURN int)

    if @mode = 22
    begin
		declare @fpID int
		select top 1 @fpID = A.ID from COM_DEPARTMENTS A with(nolock) where A.GID = '27332ba0-fd72-4383-8c0a-83b99f45c50f'/*FP*/
    
		if exists (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@fpID,1) where ID = @depId)
			set @isFP = 1
       			
       	if @isFP = 1
       	begin
       	
       		insert into @possibleTurns (DD,WTURN)
       		select cast(A.DD as datetime) 
       		,(select top 1 C.WTURN 
       		  from dbo.COM_TURNS_AROUND(dateadd(minute,B.SHORTDURATION/4,B.SHORTSTART),A.WTID,@emplid) C 
			  order by C.DIFFABS )   
			from dbo.COM_EMPLOYED_DAYS_BY_DEP2(@depId,@emplID,@dBeg,@dEnd,1) A
       		left join COM_VACATION B with(nolock) on cast(B.DBEG as date) = cast(A.DD as datetime) and B.EMPLID = @emplID
       		where B.VACATIONTYPE = 200       		
       		
       	
       	end		
			
    end


    ;with 
	 cte
	  as (select cast(DDATE as datetime) as dt from dbo.COM_DAY_PERIOD(@dBeg,@dEnd))
	,workdays
	  as (select dt from cte where dbo.COM_IS_WORKDAY2(dt,@calendar,@whID) = 1)  
	,workdays_with_turn
	  as (select dt
	            ,(select G.WTURN from COM_TURNS G with (nolock) where G.EMPLID = @emplID and G.DD = dt) as wturn
	            ,(select top 1 K.WTURN from @possibleTurns K where K.DD = dt) as wPossibleTurn
	       from workdays)
	,workdays_with_turn_1
	  as (select dt,coalesce(wturn,wPossibleTurn,1) as wturn from workdays_with_turn)
	,works
	  as (select cast(A.TFROM as time) as tbeg
	            ,cast(A.TTO as time) as tend
	            ,ISNULL(A.WTURN,1) as wturn
	            /*
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 else 0 end as adddaybeg
	            , case when cast(A.TTO as time) < cast(A.TFROM as time) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
	            */
	            , case when isnull(A.TDEXTDAY,0) = 1 and cast(A.TFROM as time) < cast(A.TTO as time) then 1 when isnull(A.TDEXTDAY,0) = 2 then -1 else 0 end as adddaybeg
	            , case when (cast(A.TTO as time) < cast(A.TFROM as time) and isnull(A.TDEXTDAY,0) <> 2) or isnull(A.TDEXTDAY,0) = 1 then 1 else 0 end as addday
	            
			from COM_WORKTIME_BR A with (nolock) where A.VNESHID = @whID
		 )
	,worksall
	  as (
		  select A.dt,cast(B.tbeg as datetime) as tbeg,cast(B.tend as datetime) as tend,B.adddaybeg,B.addday
		  from workdays_with_turn_1 A
		  left join works B on B.wturn = A.wturn
		  )      
	,worksall2
	  as (
		  select dt + tbeg + isnull(adddaybeg,0) as dbeg, dt + tend + isnull(addday,0) as dend 
		  from worksall 
		  )      
	insert into	@res (DBEG,DEND)
    select dbeg, dend from worksall2		  

return

END