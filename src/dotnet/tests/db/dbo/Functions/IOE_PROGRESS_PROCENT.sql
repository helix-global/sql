CREATE function [dbo].[IOE_PROGRESS_PROCENT](@aProgressID int)
returns decimal(10,2) as 
begin

  declare @result decimal(10,2)

  select
    @result = case
        when progressAggregated.S_S = 2130064 /*Completed*/ then 100
        when chaptersAll > 0 then round(cast(chaptersDone as decimal(10,2)) / cast(chaptersAll as decimal(10,2)) * 100, 0)
    end
  from
  (
    select
      progress.S_S,
      (select count(chapter.ID) from IOE_CHAPTER chapter (nolock) where chapter.TOPICID = progress.TOPIC and chapter.S_S = 2130074 /*Confirmed*/) as chaptersAll,
      (select count(distinct progrByChapter.CHAPTERID) from IOE_PROGRESS_T progrByChapter (nolock) where progrByChapter.VNESHID = progress.ID and progrByChapter.S_S = 2130065) as chaptersDone
    from IOE_PROGRESS progress (nolock)
    where progress.ID = @aProgressID
  ) progressAggregated
  
  return @result

end