using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSetClauseError : SqlScriptSetClause<SqlSetClauseError>
        {
        #region ctor{IServiceProvider,SqlSetClauseError}
        public SqlScriptSetClauseError(IServiceProvider context,SqlSetClauseError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }