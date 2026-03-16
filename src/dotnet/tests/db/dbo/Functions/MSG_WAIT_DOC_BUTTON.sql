CREATE function [dbo].[MSG_WAIT_DOC_BUTTON](@aWaitMethodID int)
returns nvarchar(max) WITH SCHEMABINDING
as
begin

  declare @tGUID nvarchar(250)
  declare @tSubj nvarchar(250)
  declare @mName nvarchar(250)
  declare @mClr nvarchar(10)
  
  select @tGUID = A.METHODTEMPGID
        ,@tSubj = A.METHODSUBJ
        ,@mName = dbo.COM_LANG_EN(C.NAME)
        ,@mClr = isnull(A.METHODCLR,'#4da211')
  from dbo.MSG_WAIT_METHODS A with (nolock)
  left join dbo.DEF_CLASS_METHODS C with (nolock) on C.OID = A.METHODOID
  where A.ID = @aWaitMethodID

  set @tSubj = @tSubj+' '+@tGUID

  declare @res nvarchar(max)
  
  set @res = '<br>';
  set @res = @res + '<a href="mailto:IPGL-PDB@ipgphotonics.com?subject='+@tSubj+'"'  
  set @res = @res + ' style="width:150px;white-space:normal;word-break:break-all;background:'+@mClr+';text-shadow: 0 -1px 0 #0054a6;border-color:#499910;margin-bottom:5px;margin-right:10px;font-size:14px;font-family:Arial,Helvetica,sans-serif;line-height:20px;color:#ffffff;-webkit-border-radius:3px;-moz-border-radius:3px;-ms-border-radius:3px;-o-border-radius:3px;border-radius:3px;border: 8px solid '+@mClr+';text-decoration:none;box-sizing:border-box;cursor:pointer;display:inline-block;font-weight:bold;text-align:center;">'
  set @res = @res + @mName
  set @res = @res + '</a>'
  set @res = @res + '<br>'
    
  return @res;
end;