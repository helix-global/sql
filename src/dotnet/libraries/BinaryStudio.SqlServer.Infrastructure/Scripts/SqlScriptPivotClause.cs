using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptPivotClause : SqlScriptCodeObject<SqlPivotClause>
        {
        #region ctor{IServiceProvider,SqlPivotClause}
        public SqlScriptPivotClause(IServiceProvider context,SqlPivotClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }