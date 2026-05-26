using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlSetStatementError))]
    internal sealed class SqlScriptSetStatementError : SqlScriptSetStatement<SqlSetStatementError>
        {
        #region ctor{IServiceProvider,SqlSetStatementError}
        public SqlScriptSetStatementError(IServiceProvider context,SqlSetStatementError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }