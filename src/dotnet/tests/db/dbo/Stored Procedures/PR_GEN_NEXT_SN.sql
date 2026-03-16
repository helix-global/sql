CREATE procedure [dbo].[PR_GEN_NEXT_SN] 
 @OrderID int
as 
SET nocount on

declare @newSNN int;
declare @newSNC nvarchar(50);
declare @newSN nvarchar(50);

declare @devID int;
declare @depID int;
declare @snMode int;
declare @snNmin int;
declare @modelID int;
declare @sn4model int; /*искать сл. номер по маске в пределах модели*/
declare @mtypeID int;
declare @sn4mt int; /*искать сл. номер по маске в пределах типа модели*/

declare @newSNC_LAST nvarchar(50);
declare @modelID_LAST int;
declare @sn4model_LAST int; 
declare @mtypeID_LAST int;
declare @sn4mt_LAST int; 
declare @depID_LAST int


declare curSN cursor local read_only for 
select A.ID, M.DEPID, coalesce(M.SNPMODE,T.SNPMODE,0), coalesce(M.SNPMIN,T.SNPMIN,0), A.MODELID, coalesce(M.SNP4MODEL,0), M.TYPEID, coalesce(T.SNP4MTYPE,0)
  from PR_DEVICE A 
left join PR_MODELS M with (nolock) on M.ID = A.MODELID
left join PR_MODELTYPE T with (nolock) on T.ID = M.TYPEID
 where A.ORDERID = @OrderID;
 
open curSN;
WHILE 1=1
BEGIN
   FETCH NEXT FROM curSN INTO @devID,@depID,@snMode,@snNmin,@modelID,@sn4model,@mtypeID,@sn4mt;
   IF @@FETCH_STATUS<>0 BREAK;
   
   if @snMode not in (0,4)
   begin
   
      set @newSN = 'SN not assigned (id:'+LTRIM(STR(@devID))+')';
    
   end
   else
   begin 

     select @newSNC = dbo.PR_SNC(@devID);
     
     if @newSNN is not null and @depID_LAST = @depID and @newSNC_LAST = @newSNC and @modelID_LAST = @modelID and @sn4model_LAST = @sn4model and @mtypeID_LAST = @mtypeID and @sn4mt_LAST = @sn4mt
     begin
     
		set @newSNN = @newSNN+1 
     
     end
     else
     begin
     
		 select @newSNN = isnull(max(B.SNN),0)+1 
		   from PR_DEVICE B with (nolock) 
		   left join PR_MODELS M with (nolock) on M.ID = B.MODELID
		  where B.SNC = @newSNC
   			and (M.DEPID = @depID or isnull(@sn4mt,0) = 2)
   			and (B.MODELID = @modelID or isnull(@sn4model,0) <> 1)
   			and (M.TYPEID = @mtypeID or isnull(@sn4mt,0) = 0)
   			;
   			
   		set @depID_LAST = @depID	
		set @newSNC_LAST = @newSNC
		set @modelID_LAST = @modelID
		set @sn4model_LAST = @sn4model
		set @mtypeID_LAST = @mtypeID
		set @sn4mt_LAST = @sn4mt
   			
   	 end		
	  
	  if @snNmin > 0
	    if @newSNN < @snNmin
	    begin
	    
 	   if not exists (select A.ID from PR_DEVICE A with (nolock)
 	                  where A.MODELID = @ModelID
					    and A.SNC is not null
						and A.SNN is not null
						and A.ID <> @devID)
	      
	      set @newSNN = @snNmin
	      
	    end
	
   	  if charindex('{O}',@newSNC) > 0
   	     if @newSNN % 2 = 0
   	       SET @newSNN = @newSNN + 1
   	  if charindex('{E}',@newSNC) > 0
   	     if @newSNN % 2 = 1
   	       SET @newSNN = @newSNN + 1
	

	
      set @newSN = dbo.PR_SN(@newSNC,@newSNN,@devID);
   
	  /*
	  TODO 
	  1) проверять что разрядов # хватает для @newSNN
	  и что делать когда не хватит
	  2) если номер уже есть (был введен вручную) - пропустить
	  вопрос - сколько попыток предпринять
	  */

	   
   end
   
   update PR_DEVICE set SN = @newSN, SNC = @newSNC, SNN = @newSNN where ID = @devID;
   
END
close curSN;
deallocate curSN;

SET nocount off