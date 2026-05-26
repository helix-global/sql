using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlComparisonBooleanExpression))]
    internal sealed class SqlScriptComparisonBooleanExpression : SqlScriptBooleanExpression<SqlComparisonBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlComparisonBooleanExpression}
        public SqlScriptComparisonBooleanExpression(IServiceProvider context,SqlComparisonBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }