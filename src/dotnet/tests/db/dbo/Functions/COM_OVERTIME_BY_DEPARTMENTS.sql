CREATE function [dbo].[COM_OVERTIME_BY_DEPARTMENTS] (@UserID int, @aMode int)
returns @res table (DEPID int, YY int, MM int, WORKPLANS_M decimal(18,2), VACATIONS_M decimal(18,2), OVERTIME_M decimal(18,2), DBEG datetime, DEND datetime, SHORT_ABS decimal(18,2) )
as 
begin

   declare @now datetime
   set @now = getdate()
   
   declare @from datetime
   set @from = dateadd(month,-7,@now)
   
   declare @rootdepid int
   select @rootdepid = A.ID from COM_DEPARTMENTS A with (nolock) where A.CODE = 'IPGL'


   insert into @res (DEPID, YY, MM, DBEG, DEND)
   select A.ID,B.YY,B.MM,B.DBEG,B.DEND_NEXT
   from COM_DEPARTMENTS A with (nolock)
   cross apply dbo.COM_MONTH_PERIOD(dateadd(month,-7,@now),dateadd(month,-1,@now)) B
   where A.ID in (select distinct C.DEPID from COM_EMPLOYEE C with (nolock))
     and A.ID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@rootdepid,0))


   declare @vacations table (DEPID int,YY int,MM int,RES decimal(18,2) primary key (DEPID,YY,MM))
   insert into @vacations (DEPID,YY,MM,RES)
   select B.DEPID,year(C.DD),month(C.DD),sum(C.MINUTES)
   from COM_VACATION A with (nolock)
   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
   outer apply dbo.COM_VACATION_MINUTES_BYDAYS(A.ID) C
	where B.DEPID in (select distinct DEPID from @res)
	  and A.S_S in (1000141,2130051)
	  and isnull(A.DEND,A.DBEG) >= @from
	  and A.DBEG <= @now
	  and C.DD is not null
	group by B.DEPID,year(C.DD),month(C.DD)


   declare @shortAbsence table (DEPID int,YY int,MM int,RES decimal(18,2) primary key (DEPID,YY,MM))
   
   if @aMode = 2
   begin
   
	   insert into @shortAbsence (DEPID,YY,MM,RES)
	   select B.DEPID,year(C.DD),month(C.DD),sum(C.MINUTES)
	   from COM_VACATION A with (nolock)
	   left join COM_EMPLOYEE B with (nolock) on B.ID = A.EMPLID
	   outer apply dbo.COM_VACATION_MINUTES_BYDAYS(A.ID) C
		where B.DEPID in (select distinct DEPID from @res)
		  and A.S_S in (1000141,2130051)
		  and A.VACATIONTYPE = 30 /*  SHORT ABSENCE */
		  and isnull(A.DEND,A.DBEG) >= @from
		  and A.DBEG <= @now
		  and C.DD is not null
		group by B.DEPID,year(C.DD),month(C.DD)

   end

   update @res set VACATIONS_M = (select isnull(sum(B.RES),0) 
                                  from @vacations B 
                                 where B.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2("@res".DEPID,1))
                                   and B.YY = "@res".YY 
                                   and B.MM = "@res".MM)

   declare @workedplans table (DEPID int, YY int, MM int, RES decimal(18,2) primary key (DEPID,YY,MM))
   
   insert into @workedplans (DEPID, YY, MM, RES)
   select A.DEPID
         ,A.YY
         ,A.MM
         ,dbo.COM_WORKP_MINUTS_BY_DEPARTMENT(A.DBEG,A.DEND,A.DEPID,1) 
   from @res A

   update @res set WORKPLANS_M = (select isnull(sum(B.RES),0)
                                    from @workedplans B
                                   where B.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2("@res".DEPID,1))
                                     and B.YY = "@res".YY 
                                    and B.MM = "@res".MM)
                                 
   declare @overtimes table (DEPID int, YY int, MM int, RES decimal(18,2) primary key (DEPID,YY,MM))
   
   insert into @overtimes (DEPID, YY, MM, RES)
   select A.DEPID
         ,A.YY
         ,A.MM
         ,dbo.COM_OVERTIME_MINUTS_BY_DEPARTMENT(A.DBEG,A.DEND,A.DEPID,2) 
   from @res A
                                 
   update @res set OVERTIME_M = (select isnull(sum(B.RES),0)
                                    from @overtimes B
                                   where B.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2("@res".DEPID,1))
                                     and B.YY = "@res".YY 
                                    and B.MM = "@res".MM)

   if @aMode = 2
   begin
       update @res set SHORT_ABS = (select isnull(sum(B.RES),0)
                                    from @shortAbsence B
                                   where B.DEPID in (select ID from dbo.COM_GETCHILD_DEPARTMENTS2("@res".DEPID,1))
                                     and B.YY = "@res".YY 
                                     and B.MM = "@res".MM)

   end
                      
   return 
    
end