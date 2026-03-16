CREATE FUNCTION [dbo].[COM_STRING_SPLIT]
(
@string NVARCHAR(MAX),
@delimiter CHAR(1)
)
RETURNS @output TABLE(idx int, splitdata NVARCHAR(MAX)
)
BEGIN
DECLARE @idx INT, @start INT, @end INT
SELECT @idx=0, @start = 1, @end = CHARINDEX(@delimiter, @string)
WHILE @start < LEN(@string) + 1 BEGIN
IF @end = 0
SET @end = LEN(@string) + 1

INSERT INTO @output (idx, splitdata)
VALUES(@idx, SUBSTRING(@string, @start, @end - @start))
SET @start = @end + 1
SET @idx = @idx + 1
SET @end = CHARINDEX(@delimiter, @string, @start)

END
RETURN
END