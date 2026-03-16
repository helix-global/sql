CREATE procedure [dbo].[PR_CHECK_OR_NOTIFY_STARTED] @OperID int, @aMode int, @UserID int 
as 
set nocount on

declare @TestOrder int
declare @DoNotCheckSkills int

select @TestOrder = isnull(B.TESTORDER,0)
      ,@DoNotCheckSkills = isnull(C.DONOTCHECKSKILLS,0) 
from PR_OPERATION A with (nolock)
left join PR_PRORDER B with (nolock) on B.ID = A.ORDERID
left join PR_OPERATIONS C  with (nolock) on C.ID = A.OPERTYPEID 
where A.ID = @OperID

if @TestOrder <> 1
begin

	declare @HistFormID int
	select @HistFormID = max(A.ID) 
	  from PR_OPERATIONS_HISTORY A with (nolock)
	 where A.FORMID = (select B.OPERTYPEID
						 from PR_OPERATION B with (nolock)
						where B.ID = @OperID)

	if @HistFormID is null
	begin
	  raiserror('Approved form for this operation does not exists. Please contact supervisor.[L=pr_no_approved_form',15,0)
	  set nocount off
	  return
	end 
	else 
	  update PR_OPERATION set OPERFORMHISTID = @HistFormID 
	   where ID = @OperID and OPERFORMHISTID is null

end

declare @startedSN nvarchar(max)
set @startedSN = ''

select top 10 @startedSN = @startedSN + isnull(B.SN,C.NAME) + '; '
from PR_OPERATION A with (nolock)
left join PR_DEVICE B with (nolock) on B.ID = A.DEVICEID
left join PR_OPERATIONS C  with (nolock) on C.ID = A.OPERTYPEID 
where A.S_S in (1000031/*,1000033*/)
  and A.COMPLETED_DT is null
  and A.ID <> @OperID
  and A.USERINPROGRESS = @UserID
  
if len(@startedSN) > 1  
begin
  declare @denyParralel int
  declare @operType int
  declare @limitValue int
  
  select @denyParralel = isnull(B.DENYPARRALEL,0)
        ,@operType = A.OPERTYPEID 
        ,@limitValue = B.DENYPARRALELLIMIT
  from PR_OPERATION A with (nolock) 
  left join PR_OPERATIONS B with (nolock) on B.ID = A.OPERTYPEID 
  where A.ID = @OperID
  
  if @denyParralel = 1
  begin
  
	  if not exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
		and A.OPERTYPEID = @operType
		)
		set @denyParralel = 0

  end			
  else if @denyParralel = 2
  begin
  
	  if not exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
		)
		set @denyParralel = 0

  end		
  else if @denyParralel = 3
  begin
  
	  if not exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
	    and A.OPERTYPEID <> @operType
		)
		set @denyParralel = 0

  end		
  else if @denyParralel = 4
  begin

	  if not exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
	    and A.OPERTYPEID <> @operType
		)
		BEGIN
 
          if @limitValue is null
          BEGIN
          
			set @denyParralel = 0
			
          END 
          ELSE
          BEGIN
          
		     declare @pExists int 
		     
			 select @pExists = count(A.ID)
	         from PR_OPERATION A with (nolock)
			where A.S_S in (1000031/*,1000033*/)
			  and A.COMPLETED_DT is null
	          and A.ID <> @OperID
			  and A.USERINPROGRESS = @UserID
			
			if @pExists < @limitValue 
			    set @denyParralel = 0
			    
		   END 
		END

  end		
  else if @denyParralel = 0 /* запускается незапрещенная операция но у оператора начата операция, запрещающая все другие*/
  begin

	  if exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  left join PR_OPERATIONS B  with (nolock) on B.ID = A.OPERTYPEID 
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
		and isnull(B.DENYPARRALEL,0) = 2
		)
		set @denyParralel = 1

      /*у оператора есть операция запрещающая другие типы операций */
	  if exists (
	  select A.ID
	  from PR_OPERATION A with (nolock)
	  left join PR_OPERATIONS B  with (nolock) on B.ID = A.OPERTYPEID 
	  where A.S_S in (1000031/*,1000033*/)
	    and A.COMPLETED_DT is null
	    and A.ID <> @OperID
	    and A.USERINPROGRESS = @UserID
	    and A.OPERTYPEID <> @operType
		and isnull(B.DENYPARRALEL,0) = 3
		)
		set @denyParralel = 1

    
  end
  
  if @denyParralel <> 0
  begin
    print '#wYou have other started operations with following items:[L=pr_have_other_started'
    print '#w'+@startedSN
    raiserror('Cannot start the operation while other operations not completed.[L=pr_cannot_start_oth_ncmpl',16,0)
	set nocount off
	return
  end
  else
  begin 
    print '#wYou have other started operations with following items:[L=pr_have_other_started'
    print '#w'+@startedSN
  end	
end  

declare @spw int
set @spw = dbo.DEF_USERINGROUP(@UserID,17/*supervisor*/,getdate())

if @spw = 0
begin
	declare @crUserID int
	declare @forceUserID int
	declare @changeRequired int

	select @crUserID = isnull(A.S_CR,-4217)
		  ,@changeRequired = isnull(B.USERCHREQUIRED,0)
		  ,@forceUserID = ISNULL(A.USERINPROGRESS,-452)
	from PR_OPERATION A with (nolock)
	left join PR_MAP_OPER B with (nolock) on B.ID = A.REVOPERID
	where A.ID = @OperID

	if (@changeRequired = 1 and @crUserID = @UserID and @UserID <> @forceUserID)
		raiserror('You cannot start this operation because changing of operator requires.[L=pr_you_cannot_start',16,0)

	declare @now datetime
	set @now = getdate()

	declare @CurrUrg int
	declare @OperType2 int

	/*select @CurrUrg = coalesce(A.URGENCY,T1000870.URGENCY,T1000240.URGENCY) */
	select @CurrUrg = dbo.PR_OPER_URGENCY3(A.ID,A.ORDERID,T1000241.ORDERID,T1000240.URGENCY,T1000870.URGENCY,A.URGENCY)
 	     , @OperType2 = A.OPERTYPEID
	from PR_OPERATION A with (nolock)
	left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
	left join PR_DEVICE T1000241 with (nolock) on T1000241.ID = A.DEVICEID  
	left join PR_SUPPLY T1000870 with (nolock) on T1000870.ID = T1000241.SORDERID
	where A.ID = @OperID

	if (isnull(@CurrUrg,0) < 10) 
	begin
	  declare @myEXCopers table (ID int,S_S int,USERINPROGRESS int)
	  
	  /*для ускорения отбираются операции с эксклюзивным приоритетом вообще */
	  insert into @myEXCopers (ID,S_S,USERINPROGRESS)
	  select A.ID,A.S_S,A.USERINPROGRESS
	  from PR_OPERATION A with (nolock)
	  left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
	  left join PR_DEVICE T1000241 with (nolock) on T1000241.ID = A.DEVICEID  
	  left join PR_SUPPLY T1000870 with (nolock) on T1000870.ID = T1000241.SORDERID
	  left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID  
	  where A.COMPLETED_DT is null
		and dbo.PR_OPER_URGENCY3(A.ID,A.ORDERID,T1000241.ORDERID,T1000240.URGENCY,T1000870.URGENCY,A.URGENCY) = 10
		and A.OPERTYPEID = @OperType2
		and (T1000242.OPERGRID in (select ID from dbo.PR_ACCESS_OPERGROUPS_ONLY_MY(@UserID,@now)) or A.USERINPROGRESS = @UserID)
		and A.S_S = 1000032 /*pending*/

	  insert into @myEXCopers (ID,S_S,USERINPROGRESS)
	  select A.ID,A.S_S,A.USERINPROGRESS
	  from PR_OPERATION A with (nolock)
	  left join PR_OPERATIONS T1000242 with (nolock) on T1000242.ID = A.OPERTYPEID  
	  where A.MNT_PLANID is not null
	    and A.COMPLETED_DT is null
	    and A.DEVICEID is null
		and A.URGENCY = 10
		and (T1000242.OPERGRID in (select ID from dbo.PR_ACCESS_OPERGROUPS_ONLY_MY(@UserID,@now)) or A.USERINPROGRESS = @UserID)
		and A.S_S = 1000032 /*pending*/
		
	  if exists 
	   (	
		  select top 1 A.ID 
			from @myEXCopers A
		   where dbo.PR_IS_MY_CURRENT_OPERATION(A.ID,A.S_S,A.USERINPROGRESS,@UserID,@now) = 1
		     and (A.ID in (select BB.ID from dbo.PR_IS_MY_CO_NEW(@UserID,@now) BB))  /*KB3739*/
		)
		 raiserror('Operation with "Exceptional" urgency exists. Please do it first.[L=pr_exceptional_pr_exists',15,0)
	end

	if (isnull(@CurrUrg,-1) = 0) /*оператор берется за LOW приоритетную операцию */
	begin
	  if exists 
	  (
		 select top 1 A.ID
		 from PR_OPERATION A with (nolock)
		 left join PR_PRORDER T1000240 with (nolock) on T1000240.ID = A.ORDERID
		 left join PR_DEVICE T1000241 with (nolock) on T1000241.ID = A.DEVICEID  
		 left join PR_SUPPLY T1000870 with (nolock) on T1000870.ID = T1000241.SORDERID
		 where A.COMPLETED_DT is null
		   and dbo.PR_OPER_URGENCY3(A.ID,A.ORDERID,T1000241.ORDERID,T1000240.URGENCY,T1000870.URGENCY,A.URGENCY) > 0
   		   and A.OPERTYPEID = @OperType2
		   and dbo.PR_IS_MY_CURRENT_OPERATION(A.ID,A.S_S,A.USERINPROGRESS,@UserID,getdate()) = 1
	  )
	  raiserror('Operation with higher urgency exists. Please do it first.[L=pr_higher_pr_exists',15,0)
	end
end

if isnull(@DoNotCheckSkills,0) <> 1
begin
--training

	--проверка на тренинги и наличие навыков

	declare @skillDeps table (ID int) --тестирование - только для некоторых отделов

	insert into @skillDeps (ID)
	select ID from dbo.COM_DEPS_SKILL_MATRIX()


	declare @depID int
	set @depID=dbo.COM_USER_DEPARTMENT(@UserID)


	
	if @depID in(select ID from @skillDeps) 
	begin
		declare @code int, @textErr nvarchar(max)
		declare @action int = 0


		select @code=CODE, @textErr=ERR_TEXT from dbo.COM_CHECK_SKILL_AND_TRAINING(@OperID, @UserID)

		if @code>0
		begin
			select @action=isnull(D.NO_SKILL_ACTION,0)
				from COM_DEPARTMENTS D
					where D.ID=@depID

			if @action=0
				print '#W' + @textErr

			if @action=1
			/*KB4423 => */
				-- When Checking trainings and skills
				-- show error message as Warning if it has CODE = 100 
				if @code = 100
					print '#W' + @textErr
				else				
				/* <= KB4423*/
					-- all other codes
			    raiserror(@textErr,15,0)
		end

	end
end

set nocount off