CREATE function [dbo].[COM_DEP_EMPLWORKDAYS_TAB] (@DepID int, @dBeg date, @dEnd date, @aMode int)
returns @res table (DD date, EMPLID int, AVAIL decimal(12,2), AVAILINPROD decimal(12,2))
as 
begin
   /* 
   функция возвращает рабочие даты сотрудников отдела
   учитываются переходы между отделами
   отпуск вычитается
   добавляются дни в которых введена переработка
   @aMode = 1 - вместе дочерними подразделениями
   AVAIL - рабочих минут в дне
   AVAILINPROD - рабочих минут в дне согласно участию в производстве
   */
   
   declare @deps table (ID int not null)
   insert into @deps (ID) values (@DepID)
   
   if @aMode = 1
   begin
     insert into @deps (ID) 
     select ID from dbo.COM_GETCHILD_DEPARTMENTS2(@DepID,0)
   end
   
   declare @empl table (ID int not null, WTID int, CALENDAR int)
    
   insert into @empl(ID,WTID,CALENDAR)
   select A.ID
       , ISNULL(A.PERSONALWT,B.ID)
       , ISNULL(B2.CALENDAR,B.CALENDAR)
   from COM_EMPLOYEE A with (nolock) 
   left join COM_WORKTIME B with (nolock) on B.DEPID = A.DEPID and isnull(B.WTDEFAULT,0) = 1
   left join COM_WORKTIME B2 with (nolock) on B2.ID = A.PERSONALWT
   where A.ID in (select B.ID from COM_EMPLOYEE B with (nolock) where B.DEPID in (select ID from @deps)
                  union   
                  select H.EMPLID from COM_EMPL_PERIODS H with (nolock) where H.DEPID in (select ID from @deps)
                    and H.DBEG <= @dEnd
                    and isnull(H.DEND,'40000101') >= @dBeg 
                  )
                  
     

   insert into @res (DD,EMPLID,AVAIL)
   select DDATE
     ,ID
     ,dbo.COM_WORK_MINUTS6(DDATE, dateadd(day,1,DDATE), WTID, CALENDAR, ID)
   from (
   select A.DDATE
         ,B.ID
         ,B.CALENDAR
         ,B.WTID
   from dbo.COM_DAY_PERIOD(@dBeg,@dEnd) A
   cross join @empl B
   where dbo.COM_IS_WORKDAY2(A.DDATE,B.CALENDAR,B.WTID) = 1
      or exists (select J.ID from COM_ADDED_WORKTIME J with (nolock) 
                  where J.EMPLID = B.ID 
                    and cast(J.DBEG as date) = A.DDATE
                 )
   )M
   where exists (select KK.ID from @deps KK where dbo.COM_EMPLOYEE_IN_DEP2(M.ID, KK.ID, M.DDATE) = 1)         
           
   update @res set AVAILINPROD=AVAIL * dbo.PRR_PART_IN_PROD2(A.EMPLID,A.DD,A.DD) / 100
		from @res A
                      
   return
    
end