CREATE TABLE [dbo].[DEF_CUSTOM_VIEWS] (
    [ID]           INT              IDENTITY (1, 1) NOT NULL,
    [GID]          UNIQUEIDENTIFIER NULL,
    [S_CR]         INT              NOT NULL,
    [S_CDT]        DATETIME         NOT NULL,
    [S_MR]         INT              NULL,
    [S_MDT]        DATETIME         NULL,
    [ARC]          INT              NULL,
    [USERID]       INT              NOT NULL,
    [NAME]         NVARCHAR (350)   NOT NULL,
    [DESCSTR]      NTEXT            NULL,
    [CLASSOID]     INT              NOT NULL,
    [VIEWOID]      INT              NULL,
    [SQLTEXT]      NTEXT            NULL,
    [TEMPLATE]     IMAGE            NULL,
    [POSORDER]     INT              NULL,
    [CONTEXTID]    INT              NULL,
    [CONTEXTIDS]   NTEXT            NULL,
    [ITEMTYPEID]   INT              NULL,
    [ADDEDCOLUMNS] IMAGE            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DEF_CUSTOM_VIEWS_CLASSOID] FOREIGN KEY ([CLASSOID]) REFERENCES [dbo].[DEF_CLASSES] ([OID]),
    CONSTRAINT [FK_DEF_CUSTOM_VIEWS_USERID] FOREIGN KEY ([USERID]) REFERENCES [dbo].[DEF_USERS] ([ID]),
    CONSTRAINT [FK_DEF_CUSTOM_VIEWS_VIEWOID] FOREIGN KEY ([VIEWOID]) REFERENCES [dbo].[DEF_VIEWS] ([OID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID типа item''а для кастомных view когда он (view) сосздается с закладки с выбранным типом (KB2089)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DEF_CUSTOM_VIEWS', @level2type = N'COLUMN', @level2name = N'ITEMTYPEID';

