CREATE TABLE [dbo].[temp_check_packet_ids] (
    [ID] INT IDENTITY (1, 1) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_temp_check_packet_ids]
    ON [dbo].[temp_check_packet_ids]([ID] ASC);

