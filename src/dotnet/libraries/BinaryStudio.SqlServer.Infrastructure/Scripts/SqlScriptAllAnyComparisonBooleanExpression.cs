using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlAllAnyComparisonBooleanExpression))]
    internal sealed class SqlScriptAllAnyComparisonBooleanExpression : SqlScriptBooleanExpression<SqlAllAnyComparisonBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlAllAnyComparisonBooleanExpression}
        public SqlScriptAllAnyComparisonBooleanExpression(IServiceProvider context,SqlAllAnyComparisonBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }