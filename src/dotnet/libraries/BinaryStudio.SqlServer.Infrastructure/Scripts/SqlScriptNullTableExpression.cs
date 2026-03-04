using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlNullTableExpression))]
    internal sealed class SqlScriptNullTableExpression : SqlScriptTableExpression<SqlNullTableExpression>
        {
        #region ctor{IServiceProvider,SqlNullTableExpression}
        public SqlScriptNullTableExpression(IServiceProvider context,SqlNullTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }