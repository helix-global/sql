using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSearchedWhenClause : SqlScriptScalarExpression<SqlSearchedWhenClause>
        {
        #region ctor{IServiceProvider,SqlSearchedWhenClause}
        public SqlScriptSearchedWhenClause(IServiceProvider context,SqlSearchedWhenClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }