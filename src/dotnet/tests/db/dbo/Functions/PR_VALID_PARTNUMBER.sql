CREATE function dbo.PR_VALID_PARTNUMBER(@aCode nvarchar(50))
returns int
as
begin

  if (dbo.DEF_SYS_CONST_STR('com_remotelocation_code', '') = 'IPGP')
  begin 
    return 1
  end

  declare @pnLen int
  set @pnLen = LEN(@aCode)
  if @pnLen <> 14 and @pnLen <> 16
    return 0

  declare @test nvarchar(50)
  set @test = upper(@aCode)

  if @pnLen = 14 and @test not like '[0-9A-Z][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&]'
    return 0

  if @pnLen = 16 and @test not like '[0-9A-Z][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&][0-9A-Z&]'
    return 0

    
  return 1

end;