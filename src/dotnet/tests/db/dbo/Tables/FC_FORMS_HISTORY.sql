CREATE TABLE [dbo].[FC_FORMS_HISTORY] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [FORMXML]      NTEXT            NULL,
    [FORMID]       INT              NULL,
    [FORM_MDT_KEY] DATETIME         NULL,
    [FTYPE]        INT              NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_FC_FORMS_HISTORY_FORMID] FOREIGN KEY ([FORMID]) REFERENCES [dbo].[FC_FORMS] ([ID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_FC_FORMS_HISTORY]
    ON [dbo].[FC_FORMS_HISTORY]([FORMID] ASC);

