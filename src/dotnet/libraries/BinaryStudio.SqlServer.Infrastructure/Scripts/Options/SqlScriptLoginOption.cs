using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlLoginOption))]
    internal sealed class SqlScriptLoginOption : SqlScriptCodeObject<SqlLoginOption>
        {
        public SqlLoginOptionType Type {get{ return Source.Type; }}

        #region ctor{IServiceProvider,SqlLoginOption}
        public SqlScriptLoginOption(IServiceProvider context,SqlLoginOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }