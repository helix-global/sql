using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlExecuteArgument))]
    internal sealed class SqlScriptExecuteArgument : SqlScriptCodeObject<SqlExecuteArgument>
        {
        #region ctor{IServiceProvider,SqlExecuteArgument}
        public SqlScriptExecuteArgument(IServiceProvider context,SqlExecuteArgument source)
            : base(context,source)
            {
            }
        #endregion
        }
    }