using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDerivedTableExpression))]
    internal sealed class SqlScriptDerivedTableExpression : SqlScriptTableExpression<SqlDerivedTableExpression>
        {
        #region ctor{IServiceProvider,SqlDerivedTableExpression}
        public SqlScriptDerivedTableExpression(IServiceProvider context,SqlDerivedTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }