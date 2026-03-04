using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBooleanFilterExpression))]
    internal sealed class SqlScriptBooleanFilterExpression : SqlScriptFilterExpression<SqlBooleanFilterExpression>
        {
        #region ctor{IServiceProvider,SqlBooleanFilterExpression}
        public SqlScriptBooleanFilterExpression(IServiceProvider context,SqlBooleanFilterExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }