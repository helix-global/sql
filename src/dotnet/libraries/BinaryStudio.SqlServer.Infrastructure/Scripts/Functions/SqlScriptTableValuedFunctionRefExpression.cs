using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTableValuedFunctionRefExpression))]
    internal sealed class SqlScriptTableValuedFunctionRefExpression : SqlScriptTableExpression<SqlTableValuedFunctionRefExpression>
        {
        #region ctor{IServiceProvider,SqlTableValuedFunctionRefExpression}
        public SqlScriptTableValuedFunctionRefExpression(IServiceProvider context,SqlTableValuedFunctionRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }