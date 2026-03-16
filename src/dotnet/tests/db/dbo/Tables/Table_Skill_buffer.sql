CREATE TABLE [dbo].[Table_Skill_buffer] (
    [ID]       INT             NOT NULL,
    [NAME]     NVARCHAR (4000) NOT NULL,
    [SKILL_ID] INT             NULL,
    CONSTRAINT [PK_Table_Skill_buffer] PRIMARY KEY CLUSTERED ([ID] ASC)
);

