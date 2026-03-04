using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlExecuteStringStatement))]
    internal sealed class SqlScriptExecuteStringStatement : SqlScriptExecuteStatement<SqlExecuteStringStatement>
        {
        #region ctor{IServiceProvider,SqlExecuteStringStatement}
        public SqlScriptExecuteStringStatement(IServiceProvider context,SqlExecuteStringStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }