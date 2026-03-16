CREATE procedure dbo.LDM_SETCHIP_SN  @DeviceID int, @OperID int, @UserID int
as 
set nocount on

declare @oldSN nvarchar(50)
declare @depID int
declare @ModelID int

select 
 @oldSN = D.SN
,@depID = M.DEPID
,@ModelID = D.MODELID
from PR_DEVICE D with (nolock)
left join PR_MODELS M with (nolock) on M.ID = D.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
where D.ID = @DeviceID

  
	if CHARINDEX('not assigned',@oldSN) > 0
	begin
   
    declare @snPrefix char = 'D' -- D for diode
		declare @newSNN int
		declare @newSNC nvarchar(50)

    if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPGL')
    begin 
      set @snPrefix = 'B'
    end

    if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPM')
    begin 
      set @snPrefix = 'R'
    end

		/* 
		   метка для нумерации 
		   GYYLDM_CHIP
		   метка пишется в SNC как обычно с целью следующего поиска, в SNN как обычно последний использованный номер
		*/

        declare @yy nvarchar(2) = SUBSTRING(RTRIM(LTRIM(STR(YEAR(getdate())))),3,2);
		
		set @newSNC = @snPrefix+@yy+'LDM_CHIP'
		
		select @newSNN = isnull(max(B.SNN),0)+1 
		 from PR_DEVICE B with (nolock) 
 		left join PR_MODELS M with (nolock) on M.ID = B.MODELID
		where B.SNC = @newSNC
		  and M.DEPID = @depID
         
		declare @minSNval int
		select @minSNval = dbo.LDM_SETTING_INT('fac_operation1_minSN',0)
		if @newSNN < @minSNval
		  set @newSNN = @minSNval  
         
         
        declare @snCh nvarchar(20)
        set @snCh = @snPrefix + @yy + dbo.LDM_CHARSN(5,@newSNN)
	   
		update PR_DEVICE set SN = @snCh, SNC = @newSNC, SNN = @newSNN where ID = @DeviceID;
		

    end    
   


set nocount off