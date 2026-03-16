

--DECLARE @param_val sql_variant = '10,24/2'

CREATE FUNCTION dbo.PR_OPERATION_PARAM_CONVERT(@param sql_variant) 
returns sql_variant as
begin
	DECLARE @res float;
	
	DECLARE @t varchar(20) =  convert(varchar(20), @param)
	DECLARE @editedLeftPart varchar(10)
	
	if(@t like '%/%') -- if has "/"
	begin 
		declare @pos int = charindex('/',@t,1)
		declare @leftPart varchar(10)= substring(@t,1, @pos -1) -- get left part from "/"
		
		if(@leftPart like '%,%') --if left part has ","
		begin
			set @editedLeftPart = REPLACE(@leftPart,',','.') -- replace "," to "."
			set @res = convert(float, @editedLeftPart) -- result
		end
		else
		begin
			set @res = convert(float, @leftPart) --result
		end
	end
	else
	begin	-- dont have "/"
		if(@t like '%,%')	--if has ","
		begin
			set @editedLeftPart = REPLACE(@t,',','.')			-- replace "," to "."
			set @res = convert(float, @editedLeftPart)	-- result
		end
		else
		begin
			set @res = convert(float, @t)					-- result
		end
	end
	
	return convert(sql_variant, @res)
end