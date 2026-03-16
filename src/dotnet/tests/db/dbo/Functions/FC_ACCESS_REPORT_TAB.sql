CREATE function [dbo].[FC_ACCESS_REPORT_TAB](@aUserID int, @aMode int, @aDate datetime)
returns @res table (ID int) as 
begin

  declare @FR_ARC int
  set @FR_ARC = dbo.DEF_CLASS_ARC(1000111,'fc_report')

    if dbo.DEF_USERINGROUP7(@aUserID,'HRE')=1 --все отчеты, для пользователей в группе "Human Reports Editor group*/ --KB3821
	begin
		insert into @res
			select ID
				from FC_REPORT
		return
	end


	if dbo.DEF_USERINGROUP7(@aUserID,'FARALL')=1 --все отчеты, для пользователей, у которых фильтры определены во Views
	begin
		insert into @res
			select ID
				from FC_REPORT
		return
	end



  
  /* 1 если есть права на анализ или на утверждение - то вывести все по своим моделям*/
  if  dbo.DEF_F_ACCESS(@FR_ARC,null,1000131/*analized*/,@aDate,@aUserID,0) = 1
   or dbo.DEF_F_ACCESS(@FR_ARC,null,1000132/*approve*/,@aDate,@aUserID,0) = 1
  begin
     
     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     where A.MODELID in (select ID from dbo.FC_ACCESS_MODELS(@aUserID,6,@aDate))
       and A.EXTPARENTID is null
     
     if dbo.DEF_USERINGROUP4(@aUserID,'ChildFR',@aDate) = 1
     begin
        /* члены группы ChildFR видят все дочерние FR */  
		 insert into @res (ID)
		 select B.ID 
		 from @res A 
		 cross apply dbo.FC_GETCHILD_FARS(A.ID) B
        
     end
     else
     begin
     
		 /*видеть дочерние по своим */
		 insert into @res (ID)
		 select A.ID from FC_REPORT A with (nolock) 
		 where A.PARENTID in (select ID from @res)
		   and A.EXTPARENTID is null
       
     end
     
    
  end 
  else if dbo.DEF_F_ACCESS(@FR_ARC,null,1000166/*view incoming*/,@aDate,@aUserID,0) = 1
  begin

     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     where A.MODELID in (select ID from dbo.FC_ACCESS_MODELS(@aUserID,6,@aDate))
       and A.EXTPARENTID is null
     /*но без дочерних*/
     
     if @aUserID = 3180 /*нет прав анализа, но надо "видеть" */
     begin
		 insert into @res (ID)
		 select A.ID from FC_REPORT A with (nolock) 
		 where A.PARENTID in (select ID from @res)
		   and A.EXTPARENTID is null
     end
  
  end
  else if dbo.DEF_USERINGROUP4(@aUserID,'MNGD',@aDate) = 1  /*KB3529*/
  begin
  
     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
     where B.DEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,1,@aDate))       
  
  
  end

  
  /* 2 если есть права на ввод*/
  if  dbo.DEF_F_ACCESS(@FR_ARC,null,6/*create*/,@aDate,@aUserID,0) = 1
  begin
     /* 2.1 если есть права на просмотр вывести все, созданные в своем отделе (либо дочерних) */
     if  dbo.DEF_F_ACCESS(@FR_ARC,null,3/*view*/,@aDate,@aUserID,0) = 1
     begin
       insert into @res (ID)
       select A.ID from FC_REPORT A with (nolock) 
       where A.FROMDEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,6,@aDate))
         and A.EXTPARENTID is null
     end
     else
     /* 2.2 иначе только свои, но тоже созданные в своем отделе (либо дочерних) */
     begin
       insert into @res (ID)
       select A.ID from FC_REPORT A with (nolock) 
       where A.FROMDEPID in (select ID from dbo.COM_ACCESS_DEPARTMENTS(@aUserID,3,@aDate))
         and A.S_CR = @aUserID
         and A.EXTPARENTID is null
     end
  end
  
  if dbo.DEF_USERINGROUP7(@aUserID,'R&D_PL') = 1
  begin
     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
     where B.DEPID = 170 /*PLA*/
       and A.EXTPARENTID is null
  end
  if @aUserID = 744 /*smaryashin*/
  begin
     insert into @res (ID)
     select A.ID from FC_REPORT A with (nolock) 
     left join PR_MODELS B with (nolock) on B.ID = A.MODELID
     where B.TYPEID = 126 /*Fibers*/
       and A.EXTPARENTID is null
  end
 
  return
end