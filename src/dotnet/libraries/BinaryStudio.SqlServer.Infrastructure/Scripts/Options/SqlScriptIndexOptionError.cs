using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlIndexOptionError))]
    internal sealed class SqlScriptIndexOptionError : SqlScriptIndexOption<SqlIndexOptionError>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.Invalid; }}

        #region ctor{IServiceProvider,SqlIndexOptionError}
        public SqlScriptIndexOptionError(IServiceProvider context,SqlIndexOptionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }