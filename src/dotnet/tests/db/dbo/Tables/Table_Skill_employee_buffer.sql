CREATE TABLE [dbo].[Table_Skill_employee_buffer] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [SK_ID]       INT            NOT NULL,
    [EMPLOYEE]    NVARCHAR (500) NOT NULL,
    [EMPLOYEE_ID] INT            NULL,
    [SKILL_ID]    INT            NULL,
    CONSTRAINT [PK_Table_Skill_employee_buffer] PRIMARY KEY CLUSTERED ([ID] ASC)
);

