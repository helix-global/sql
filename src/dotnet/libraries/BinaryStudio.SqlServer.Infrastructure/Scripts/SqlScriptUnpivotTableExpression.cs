using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlUnpivotTableExpression))]
    internal sealed class SqlScriptUnpivotTableExpression : SqlScriptTableExpression<SqlUnpivotTableExpression>
        {
        #region ctor{IServiceProvider,SqlUnpivotTableExpression}
        public SqlScriptUnpivotTableExpression(IServiceProvider context,SqlUnpivotTableExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }