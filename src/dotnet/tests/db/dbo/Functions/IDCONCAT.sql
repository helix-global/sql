CREATE AGGREGATE [dbo].[IDCONCAT](@input INT NULL)
    RETURNS NVARCHAR (MAX)
    EXTERNAL NAME [A2Utils].[IDCONCAT];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IDCONCAT] TO [IPG-DOMAIN\Domain Users]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IDCONCAT] TO [EMEA\IPGL-PDB-External_Domains_Users]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IDCONCAT] TO [EMEA\Domain Users]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IDCONCAT] TO [A2]
    AS [dbo];

