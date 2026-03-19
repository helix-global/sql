CREATE TABLE [dbo].[MOBILE_PUSH_TOKENS] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [DeviceID]     VARCHAR (50)  NOT NULL,
    [Token]        VARCHAR (250) NOT NULL,
    [UserName]     VARCHAR (50)  NOT NULL,
    [OSname]       VARCHAR (50)  NULL,
    [OSver]        VARCHAR (50)  NULL,
    [Manufacturer] VARCHAR (50)  NULL,
    [Model]        VARCHAR (250) NULL,
    [DeviceName]   VARCHAR (250) NULL,
    [UpdateDT]     DATETIME      DEFAULT (getdate()) NOT NULL,
    [UserID]       INT           NOT NULL,
    CONSTRAINT [PK_Table_PUSH_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Table_DeviceID_UserName]
    ON [dbo].[MOBILE_PUSH_TOKENS]([DeviceID] ASC, [UserName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Search on Device ID and UserName', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MOBILE_PUSH_TOKENS', @level2type = N'INDEX', @level2name = N'IX_Table_DeviceID_UserName';

