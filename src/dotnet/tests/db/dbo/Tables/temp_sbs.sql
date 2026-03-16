CREATE TABLE [dbo].[temp_sbs] (
    [ID]            INT            NOT NULL,
    [SN]            NVARCHAR (50)  NULL,
    [MODELCODE]     NVARCHAR (16)  NULL,
    [READYNAVMSG]   NTEXT          NULL,
    [ORDERCUSTID]   INT            NULL,
    [ORDERCUSTCODE] NVARCHAR (50)  NULL,
    [ORDERCUSTNAME] NVARCHAR (100) NULL,
    [TICKETID]      INT            NULL,
    [SBSCID]        INT            NOT NULL,
    [MSGID]         INT            NULL,
    [CUSTOMERID]    INT            NOT NULL,
    [CODE]          NVARCHAR (50)  NULL,
    [NAME]          NVARCHAR (100) NULL
);

