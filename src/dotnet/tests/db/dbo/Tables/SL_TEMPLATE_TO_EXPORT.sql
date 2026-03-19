CREATE TABLE [dbo].[SL_TEMPLATE_TO_EXPORT] (
    [ID]          INT              NOT NULL,
    [S_CDT]       DATETIME         NOT NULL,
    [VNESHID]     INT              NOT NULL,
    [OPTID]       INT              NOT NULL,
    [QUANTITY]    INT              NOT NULL,
    [OPT_CRMGUID] UNIQUEIDENTIFIER NULL,
    [OPT_CODE]    NVARCHAR (16)    NULL,
    [NAME]        NVARCHAR (300)   NULL,
    CONSTRAINT [PK__SL_TEMPL__3214EC2741A512B7] PRIMARY KEY CLUSTERED ([ID] ASC)
);

