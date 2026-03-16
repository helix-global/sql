CREATE TABLE [dbo].[temp_idle_calc] (
    [ID]  INT IDENTITY (1, 1) NOT NULL,
    [RRR] INT NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_temp_idle_calc]
    ON [dbo].[temp_idle_calc]([ID] ASC);

