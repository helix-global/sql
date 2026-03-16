CREATE PROCEDURE [dbo].[IOE_PROGRESS_COMPLETE] @ProgressID int, @UserID int, @aMode int
AS
BEGIN
	set nocount on

	declare @now datetime
	set @now = GETDATE()

	declare @chapterID int
	declare @courseID int
	declare @qCount int
	declare @nextChapterID int
	declare @PID int
	declare @pOrder int
	declare @Pstate int
	declare @emplHasQuestions int
	declare @canCloseP int
	declare @wrongAnswers int
	declare @wrongAnswersLimit int
	declare @trrID int

	select @chapterID = A.CHAPTERID
	      ,@courseID = C.TOPICID
	      ,@PID = B.ID
	 	  ,@qCount = (select count(*) from IOE_CHAPTER_QUESTIONS K with(nolock) where K.VNESHID = C.ID)
	 	  ,@pOrder = C.POSORDER
	 	  ,@Pstate = A.S_S
	 	  ,@emplHasQuestions = A.EMPLHASQUESTIONS
	 	  ,@wrongAnswers = A.WRONGANSWERS
	 	  ,@wrongAnswersLimit = C.NANSW
	 	  ,@trrID = B.TRAININGID
	from IOE_PROGRESS_T A with(nolock)
	left join IOE_PROGRESS B with(nolock) on B.ID = A.VNESHID
	left join IOE_CHAPTER C with(nolock) on C.ID = A.CHAPTERID
	where A.ID = @ProgressID
	and B.EMPLID = dbo.DEF_EMPLOYEE(@UserID)

	if @chapterID is null 
	begin
	  raiserror('Course not found or permissions denied.',16,0)
	  set nocount off
	  return 
	end

/*	
	if isnull(@qCount,0) > 0
	begin
	
	
	end
*/
   
   if @Pstate = 1 and @emplHasQuestions is null
   begin
	  raiserror('Please select a option about questions.',16,0)
	  set nocount off
	  return 
   end
   
   /*
   if @Pstate = 1 and @emplHasQuestions = 1
   begin
	  raiserror('Cannot complete this page if some questions exists.',16,0)
	  set nocount off
	  return 
   end
   */  /*KB3055*/
   
   set @canCloseP = 1
   
   if @qCount > 0 and isnull(@wrongAnswers,999999) > isnull(@wrongAnswersLimit,0)
      set @canCloseP = 0


   if @canCloseP = 1
   begin
     
	   update IOE_PROGRESS_T set S_S = 2130065 /*done*/, S_MR = @UserID, S_MDT = getdate()  where ID = @ProgressID and S_S = 1

	   select top 1 @nextChapterID = A.ID 
		from IOE_CHAPTER A with(nolock)
		where A.TOPICID = @courseID 
		  and A.ID != @chapterID
		  and A.POSORDER > @pOrder
		  and A.S_S = 2130074 /*confirmed KB3053*/
		order by A.POSORDER
	   
	   if @nextChapterID is not null
	   begin
	   
		   if not exists(select J.ID from IOE_PROGRESS_T J where J.VNESHID = @PID and J.CHAPTERID = @nextChapterID)
		   begin 
	   
			  insert into IOE_PROGRESS_T(GID,S_CR,S_CDT,S_S,VNESHID,CHAPTERID)
			  values (newid(),@UserID,getdate(),1,@PID,@nextChapterID)
			  
		   end	  

	   end

       declare @missedChapter int
	   select top 1 @missedChapter = A.ID
	     from IOE_CHAPTER A with(nolock)
	    where A.TOPICID = @courseID 
	      and not exists (select B.ID from IOE_PROGRESS_T B with(nolock) where B.VNESHID = @PID and B.CHAPTERID = A.ID and B.S_S = 2130065 /*done*/)
	      and A.S_S = 2130074 /*confirmed KB3053*/
		        
	    if @missedChapter is null 
	    begin
			update IOE_PROGRESS set S_S = 2130064 /*complete*/, COMPLETEDD = getdate() where ID = @PID and S_S = 2130063 /* in progress*/    
			
			if not exists (select G.ID from IOE_PROGRESS G where G.TRAININGID = @trrID and G.S_S in (1,2130063/*in progress*/))
			begin 
				update IOE_TRAINING set S_S = 2130062 /*complete*/ where ID = @trrID and S_S = 2130061 /*in progress*/
			end	
			
		end

    end  
    
    
    
  
	set nocount off
END