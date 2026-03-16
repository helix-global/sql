
CREATE FUNCTION [dbo].[MNT_NOTIFICATION_CYCLES_LEFT_HTMLROW](@MntPlanID int,@EqID int,@dNext int)
RETURNS nvarchar(max)
AS
BEGIN
   
declare @res nvarchar(max)

set @res = ''

declare @PlanName nvarchar(500)
declare @SN nvarchar(100)
declare @TAGN nvarchar(100)
declare @ModelName nvarchar(500)
declare @WP nvarchar(50)
declare @dep nvarchar(50)
declare @respPerson nvarchar(250)
declare @stateName nvarchar(200)

declare @linkEqID int
declare @linkSN nvarchar(100)
declare @linkTAGN nvarchar(100)
declare @linkModelName nvarchar(500)
declare @linkWP nvarchar(50)
declare @linkdep nvarchar(50)
declare @linkrespPerson nvarchar(250)
declare @linkstateName nvarchar(200)


declare @linqedEqDescr nvarchar(4000)
set @linqedEqDescr=''


select @PlanName = B.NAME
from MNT_PLAN A with (nolock)
left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERID
where A.ID = @MntPlanID

select @SN = A.SN
      ,@ModelName = B.CODE
      ,@TAGN = A.TAGN
      ,@WP = A.WORKINKPLACE
      ,@dep = C.CODE
      ,@respPerson = E.NAME
      ,@stateName = dbo.DEF_STATE_NAME_EN(A.S_S) 
from EQ_EQUIPMENT A with (nolock)
left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
left join COM_DEPARTMENTS C with (nolock) on C.ID = A.DEPID
left join COM_EMPLOYEE E with (nolock) on E.ID = A.RESP_EMPLID
where A.ID = @EqID


-- информация по linked equipment
declare @tLinkedEq table (  EqId int,
                            SN nvarchar(100),
                            TAGN nvarchar(100),
                            ModelName nvarchar(500),
                            WP nvarchar(50),
                            dep nvarchar(50),
                            RESPPERSON nvarchar(250),
                            STATENAME nvarchar(200))

insert into @tLinkedEq (    EqId,
                            SN,
                            TAGN,
                            ModelName,
                            WP,
                            dep,
                            RESPPERSON,
                            STATENAME)
select A.ID
        ,A.SN
      ,A.TAGN
      ,B.CODE
      ,A.WORKINKPLACE
      ,C.CODE
      ,E.NAME
      ,dbo.DEF_STATE_NAME_EN(A.S_S)       
from EQ_EQUIPMENT A with (nolock)
left join EQ_MODELS B with (nolock) on B.ID = A.EQMODELID
left join COM_DEPARTMENTS C with (nolock) on C.ID = A.DEPID
left join COM_EMPLOYEE E with (nolock) on E.ID = A.RESP_EMPLID
where A.ID in (select eq.EQID 
                    from [dbo].[MNT_PLAN_EQ_LINKED_EQ] eq 
                        join MNT_PLAN_EQ peq on eq.VNESHID=peq.ID
                    where peq.VNESHID=@MntPlanID and peq.EQID=@EqID)


declare @i int
set @i = 1
declare cur_MNT_NOTIFICATION_HTMLROW cursor for 
    select a.EqId
                ,a.SN
              , a.ModelName
              , a.TAGN
              , a.WP
              , a.dep
              , a.RESPPERSON
              , a.STATENAME
        from @tLinkedEq a 

open cur_MNT_NOTIFICATION_HTMLROW

fetch next from cur_MNT_NOTIFICATION_HTMLROW into @linkEqID 
                                                    ,@linkSN 
                                                  ,@linkModelName 
                                                  ,@linkTAGN
                                                  ,@linkWP
                                                  ,@linkdep
                                                  ,@linkrespPerson
                                                  ,@linkstateName
while @@FETCH_STATUS=0
begin   
    if @i>1
        set @linqedEqDescr = @linqedEqDescr + '<tr>' 
            
    set @linqedEqDescr = @linqedEqDescr + 
        '<td>'+isnull(@linkModelName,'NA')+'</td><td>'+isnull(@linkSN,'NA')+'</td><td>'+isnull(@linkTAGN,'NA')+'</td><td>'+isnull(@linkWP,'NA')+'</td><td>'+isnull(@linkdep,'NA')+'</td><td>'+isnull(@linkrespPerson,'NA')+'</td><td>'+isnull(@linkstateName,'NA')+'</td></tr>'
    
    fetch next from cur_MNT_NOTIFICATION_HTMLROW into @linkEqID 
                                                        ,@linkSN 
                                                        ,@linkModelName 
                                                        ,@linkTAGN
                                                        ,@linkWP
                                                        ,@linkdep
                                                        ,@linkrespPerson
                                                        ,@linkstateName

    set @i = @i + 1
end

if @i>1
    set @linqedEqDescr = '<tr><td colspan=''2'' rowspan=''' + cast(@i-1 as nvarchar(3)) + '''>Linked Equipment</td>' + @linqedEqDescr

close cur_MNT_NOTIFICATION_HTMLROW
deallocate cur_MNT_NOTIFICATION_HTMLROW

/*<tr><th>Maintenance Plan</th><th>Next Execution Date</th><th>Equipment Model</th><th>Equipment SN</th><th>Equipment TAG Nr.</th><th>Working Place</th><th>Department</th></tr>*/

set @res = '<tr><td>'+@PlanName+'</td><td>'+ 'cycles left: ' + convert(varchar(5),@dNext) + '' +'</td><td>'+isnull(@ModelName,'NA')+'</td><td>'+isnull(@SN,'NA')+'</td><td>'+isnull(@TAGN,'NA')+'</td><td>'+isnull(@WP,'NA')+'</td><td>'+isnull(@dep,'NA')+'</td><td>'+isnull(@respPerson,'NA')+'</td><td>'+isnull(@stateName,'NA')+'</td></tr>' 
if isnull(@linqedEqDescr,'')<>''
    set @res = @res +@linqedEqDescr + '<tr><td colspan=''9''><hr/></td></tr>'

return isnull(@res,'')

END