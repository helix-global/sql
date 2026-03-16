CREATE TABLE [dbo].[FC_NOTIFICATIONS_CONTROLDATE] (
    [NOTIFTYPE] INT      NULL,
    [NOTIFRATE] INT      NULL,
    [NOTIFDD]   DATETIME NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KB2887 - IPM - New notifications about Corrective Action', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FC_NOTIFICATIONS_CONTROLDATE';

