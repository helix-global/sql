CREATE function [dbo].IOE_IS_LAST_CHAPTER(@aProgressID int)
returns int as 
begin

  
	declare @chapterID int
	declare @courseID int
	declare @nextChapterID int
	declare @pOrder int

	select @chapterID = A.CHAPTERID
	      ,@courseID = C.TOPICID
	 	  ,@pOrder = C.POSORDER
	from IOE_PROGRESS_T A with(nolock)
	left join IOE_PROGRESS B with(nolock) on B.ID = A.VNESHID
	left join IOE_CHAPTER C with(nolock) on C.ID = A.CHAPTERID
	where A.ID = @aProgressID
    
  
   select top 1 @nextChapterID = A.ID 
    from IOE_CHAPTER A with(nolock)
    where A.TOPICID = @courseID 
      and A.ID != @chapterID
      and A.POSORDER > @pOrder
    order by A.POSORDER
  
  
  if @nextChapterID is null
    return 1
   
  
  return 0


end