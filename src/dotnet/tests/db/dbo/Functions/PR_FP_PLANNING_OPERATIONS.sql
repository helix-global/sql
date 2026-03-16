
CREATE FUNCTION [dbo].[PR_FP_PLANNING_OPERATIONS]
(
	@type int
)
RETURNS @ret table (ID int)
AS
BEGIN

	--формы операций для FP Planning Tool
	
	if @type = 1 -- Operation Task
		insert into @ret (ID)
		select ID 
			from PR_OPERATIONS O
			where O.CODE='G67-40052'
		union /*KB3646*/
		select distinct K.OPERTASKID from PR_FP_PLANNING_SETTINGS K with(nolock) where K.S_S = 4180004 /*approved*/
				--and O.S_S=1000059  --KB3292 commented
	
	if @type = 2 -- Operation Prepare
		insert into @ret (ID)
		select ID 
			from PR_OPERATIONS O
			where O.CODE='G67-35374'
 			  and O.S_S=1000059
		union /*KB3646*/
		select distinct K.OPERPREPAREID from PR_FP_PLANNING_SETTINGS K with(nolock) where K.S_S = 4180004 /*approved*/
 			  
	
	if @type = 3 -- Operation Drawing
		insert into @ret (ID)
		select ID 
			from PR_OPERATIONS O
			where O.CODE='G67-37073'
				--and O.S_S=1000059 --KB3476
		union /*KB3646*/
		select distinct K.OPERDRAWID from PR_FP_PLANNING_SETTINGS K with(nolock) where K.S_S = 4180004 /*approved*/
				

	return
END