create function [dbo].[FC_QAACODE_CHECK]( @QACodeMark int, @UserID int)
returns int
as
begin
/*
KB2180 
функция позволяет видеть "QA Analysis Codes" только пользователям с ролью "QACodes" 
*/

	if isnull(@QACodeMark,0) = 0
	  return 1
	  
	if isnull(@QACodeMark,0) = 1 and dbo.DEF_USERINGROUP1(@UserID,'QACodes') = 1
	  return 1
  
    return 0

end;