using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptOnClauseError : SqlScriptConditionClause<SqlOnClauseError>
        {
        #region ctor{IServiceProvider,SqlOnClauseError}
        public SqlScriptOnClauseError(IServiceProvider context,SqlOnClauseError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }