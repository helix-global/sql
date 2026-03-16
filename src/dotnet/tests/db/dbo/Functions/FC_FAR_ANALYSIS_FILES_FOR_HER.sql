

CREATE function [dbo].[FC_FAR_ANALYSIS_FILES_FOR_HER] (@DocumentID int)
returns @res table ([ID] [int] NOT NULL,
				[GID] [uniqueidentifier] NULL,
				[S_CR] [int] NOT NULL,
				[S_CDT] [datetime] NOT NULL,
				[S_MR] [int] NULL,
				[S_MDT] [datetime] NULL,
				[ARC] [int] NULL,
				[VNESHID] [int] NOT NULL,
				[FILENAME] [nvarchar](255) NOT NULL,
				[FILESIZE] [int] NOT NULL,
				[FILEDESC] [ntext] NULL,
				[FILEDATE] [datetime] NULL,
				[FILEBLOB] [image] NULL,
				[FILEPREVIEW] [image] NULL,
				[FILEHIDDEN] [int] NULL,
				[HERID] [int])
as 
begin

	/* KB5152 */
	
	--Declare @DocumentID int = 1217589 --11595
	Insert into @res
	select  
		F.*, 
		HER.ID as HERID
	from 
		dbo.FC_ANALYSIS_FILES  F with (nolock)
		left join dbo.FC_HUMANERROR HER with (nolock) on HER.REPORTID = F.VNESHID
	where 
		--F.VNESHID = @DocumentID
		HER.ID = @DocumentID

	return
end