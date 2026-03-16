CREATE procedure [dbo].[PR_INSTALL_5ROW] @instid int, @sn nvarchar(200),@modid int,@bomid int, @CloseWithErr int, @DevID int, @OrdID int, @DevDepID int, @UserID int
as 
set nocount on

declare @partid int 

declare @errmess nvarchar(1500)	   
declare @modelname nvarchar(200)

declare @partSS int 
declare @partSSname nvarchar(200)
declare @partAccMode int
declare @partDepID int
declare @partUseInProduction int
declare @partUseInProductionCmp int

declare @bomPartID int
declare @bomName nvarchar(50)
declare @bomSN nvarchar(50)	

set @partid = null
   
   if @modid is null 
   begin
     set @errmess = 'Cannot install component '+@sn+'. Unknown model.'
     raiserror(@errmess,16,0)	      
	 set nocount off
	 return
   end
   
   /* проверка что место @bomid свободно */
   if @bomid is not null
   begin
	   set @bomPartID = null
	   select top 1 @bomPartID = A.PARTID
	   from PR_OPERATION_INSTALL A with (nolock)
	   where A.OPERID in (select B.ID from PR_OPERATION B with (nolock) where B.DEVICEID = @DevID and B.S_S in (1000013, 1000019))
		 and A.BOMID = @bomid 
		 and A.PARTID is not null
		 and A.ID < @instid  /*чтобы иметь возможность исправлять ошибки в прошлом, нужно анализировать только записи ранее*/
		 and not exists (select II.OPERID 
                         from PR_OPERATION_UNINSTALL II with (nolock)
                         left join PR_OPERATION IIO with (nolock) ON IIO.ID = II.OPERID
                         where II.INSTALLROWID = A.ID 
                           and IIO.S_S IN (1000013, 1000019)
                          )

	     
	   if @bomPartID is not null
	   begin
		 select @bomName = A.NAME from PR_MODELTYPE_BOM A with (nolock) where A.ID = @bomid
		 select @bomSN = A.SN from PR_DEVICE A with (nolock) where A.ID = @bomPartID
		 set @errmess = 'The component '+@bomSN+' already installed to BOM item '+@bomName+'.'
   		 raiserror(@errmess,16,0)	      
   		 set nocount off
   		 return
	   end  
   end	   
   
   /*поиск SN*/
   select @partid = D.ID
         ,@partSS = D.S_S
         ,@partAccMode = dbo.PR_DEVICE_ACCOUNTING(D.ID) 
         ,@partDepID = D2.DEPID
         ,@partUseInProduction = isnull(D3.ALLOWUSEINPRODUCTION,0)
         ,@partUseInProductionCmp = isnull(D3.ALLOWUSEINPRODUCTIONCMP,0)
     from PR_DEVICE D 
     left join PR_MODELS D2 with (nolock) on D2.ID = D.MODELID
     left join PR_MODELTYPE D3 with (nolock) on D3.ID = D2.TYPEID
    where D.MODELID = @modid 
      and D.SN = @sn

   
   if (@partid is null)
   begin
   
	   if (isnull(@CloseWithErr,0) <> 1)
	   begin
		   if (select ISNULL(A.CMODE,0) from PR_MODELS A with (nolock) where A.ID = @modid) <> 1
		   begin
   			  select @modelname = isnull(M.NAME,'n\a') from PR_MODELS M with (nolock) where M.ID = @modid
			  set @errmess = 'The serial number '+@sn+' model '+@modelname+' not found.'
			  raiserror(@errmess,16,0)	  
			  set nocount off
			  return    
		   end
	   end
	   
       declare @mtid int
       declare @WholeTypeUnique int
  
       select @mtid = A.TYPEID
             ,@WholeTypeUnique = ISNULL(B.SNUNIQUE,0)
       from PR_MODELS A with (nolock) 
       left join PR_MODELTYPE B with (nolock) on B.ID = A.TYPEID 
       where A.ID = @modid
 
       if @WholeTypeUnique = 1
       begin
          declare @mmmEx nvarchar(250)
          select top 1 @mmmEx = B.NAME
            from PR_DEVICE A 
            left join PR_MODELS B with (nolock) on B.ID = A.MODELID
           where B.TYPEID = @mtid
             and A.SN = @sn 
            
           if @mmmEx is not null  
           begin
			  set @errmess = 'The component with serial number '+@sn+' of another model ('+@mmmEx+') already exists.'
			  raiserror(@errmess,16,0)	  
			  set nocount off
			  return    
           end
       end
	   
	   insert into PR_DEVICE(GID,S_CR,S_CDT,S_S,SN,MODELID,CREATEDTOORDERID,CREATEDTOINSTALLROWID)
	   values (newid(),@UserID,getdate(),1000077,@sn,@modid,@OrdID,@instid)
	   
	   set @partid = @@IDENTITY
	   
   end
   else
   begin
   
       /* бывают ситуации когда отменяют старую операцию, в которой есть компоненты, которые позже уже сняты и, например, ремонте*/
       /* в этом случае не надо проверять состояние компоненты и менять его*/
       declare @WasUninstalled int
       if exists (select C.ID
                    from PR_OPERATION_INSTALL A with (nolock)
                    left join PR_OPERATION_UNINSTALL B with (nolock) on B.INSTALLROWID = A.ID
                    left join PR_OPERATION C with (nolock) on C.ID = B.OPERID
                   where A.ID = @instid
                     and C.DEVICEID = @DevID
                     and A.OPERID < B.OPERID
                  )
               set @WasUninstalled = 1      
       if (@WasUninstalled = 1)
       begin
          set nocount off
          return
       end              
   

       /* проверка что состояние позволяет установить */
       declare @skipStateCheck int = 0
       if (@partAccMode > 0) and @partSS in (1000011/*in serv*/,1000039/*serv.compl*/,1000100/*srv postponed*/)
          set @skipStateCheck = 1  /* если батч находится в сервисе то его не нужно вообще проверять, т.к. в сервисе м.б. только часть */
          
       if @partUseInProduction = 1 and @partSS in (1000008)/*in production*/   
          set @skipStateCheck = 1
          
       if @partUseInProductionCmp = 1 and @partSS in (1000022)/*pr.compl*/ /*KB3626*/
		  set @skipStateCheck = 1
       
       if @skipStateCheck = 0
       begin 
       
	       if @partSS not in (1000010,1000030,1000022/*pr.compl см.ниже.*/,1000130/*imported см.ниже.*/,1000077,1000081,1000085,1000086,1000039/*srv.compl см.ниже*/) 
	       begin
    		 select @modelname = isnull(M.NAME,'n\a') from PR_MODELS M with (nolock) where M.ID = @modid
	    	 set @partSSname = dbo.DEF_STATE_NAME_EN(@partSS)
		     set @partSSname = ISNULL(@partSSname,'n\a')
		     set @errmess = 'Cannot install component '+@sn+' model '+@modelname+'. Current component state: '+@partSSname
		     raiserror(@errmess,16,0)
  	         set nocount off
		     return    
 	       end
	   
		   /*production completed,imported,serv.compl допускаются, но только если они - изделия своего отдела*/
		   if @partSS in (1000022,1000130,1000039)
		   begin
			  if @DevDepID <> @partDepID 
			  begin
				 select @modelname = isnull(M.NAME,'n\a') from PR_MODELS M with (nolock) where M.ID = @modid
				 set @errmess = 'Cannot install component '+@sn+' model '+@modelname+'. Component must be shipped first.'
				 raiserror(@errmess,16,0)
				 set nocount off
				 return    
			  end
		   end
		   
	   end
	   
	   /* проверка что компонент уже установлен */
	   if @partAccMode = 0 
	   begin
	      /*скрытый признак чтобы обойти исторически сложившиеся ситуации, как например RedLaser, установленный в модуль EMA повторно указывается как компонент PLA*/
	      if (select ISNULL(MB.DBLINSTALL,0) from PR_MODELTYPE_BOM MB with (nolock) where MB.ID = @bomid) = 0 
	      begin
			  declare @HostDevID int
			  set @HostDevID = dbo.PR_DEVICE_IN_DEVICE(@partid,@instid)
			  if @HostDevID is not null
			  begin
			     declare @orderN nvarchar(50)
			     select @orderN = C.NN
			     from PR_OPERATION_INSTALL A with (nolock)
			     left join PR_OPERATION B with (nolock) on B.ID = A.OPERID
			     left join PR_PRORDER C with (nolock) on C.ID = B.ORDERID
			     where A.ID = @instid
			     
				 set @errmess = 'The component '+@sn+' already installed into this device'
				 if @DevID <> @HostDevID
				 begin
				    set @errmess = 'The component '+@sn+' already installed into another device'
				    if @orderN is not null
				      set @errmess = @orderN +': '+@errmess
				      
				    declare @HostName nvarchar(200)
				    select @HostName = ': ' + A.SN + ' (' + B.NAME + ')'
				    from PR_DEVICE A with (nolock)
				    left join PR_MODELS B with (nolock) on B.ID = A.MODELID
				    where A.ID = @HostDevID
				    if @HostName is not null
				      set @errmess = @errmess + @HostName
				 end
				 set @errmess = @errmess + '.'
				 raiserror(@errmess,16,0)
  				 set nocount off
				 return    
			  end
	      end
	   end
	   
	   /*KB2692*/
	   declare @recallID int
	   declare @recallText nvarchar(250)
	   declare @recallRemark nvarchar(1024)
	   select top 1 @recallID = B.ID
	          ,@recallText = B.DESCSTR
	          ,@recallRemark = cast(B.REMARK as nvarchar(1024))
	      from PR_COMP_RECALL_T A with (nolock)    
	      left join PR_COMP_RECALL B with (nolock) on B.ID = A.VNESHID
	      where A.DEVICEID = @partid
	        and B.S_S = 2180001 /*approved*/
	      order by A.ID desc
	   if @recallID is not null
	   begin
	     set @errmess = 'Unable to install component '+@sn+' affected in recall: '+isnull(@recallText,'NA')
	     if @recallRemark is not null
			set @errmess = @errmess + '; '+@recallRemark
		 raiserror(@errmess,16,0)
		 set nocount off
		 return    
	   end   

   end
   
   update PR_OPERATION_INSTALL set PARTID = @partid where ID = @instid 
   
   update PR_DEVICE set S_S = 1000077 /* Installed */ /*, SHIPPINGSTOCK = null*//*убрано по KB4212*/
	where PR_DEVICE.ID = @partid
	  and PR_DEVICE.S_S in (1000010/*shipped*/,1000030/*shipped*/,1000085/*shipped*/,1000086/*installcanceled*/
						   ,1000081/*uninstalled*/,1000022/*prod.compl*/,1000130/*imported*/,1000039/*repair cmpl KB428*/) 
	                       


set nocount off