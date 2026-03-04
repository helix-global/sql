using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBinaryFilterExpression))]
    internal sealed class SqlScriptBinaryFilterExpression : SqlScriptFilterExpression<SqlBinaryFilterExpression>
        {
        #region ctor{IServiceProvider,SqlBinaryFilterExpression}
        public SqlScriptBinaryFilterExpression(IServiceProvider context,SqlBinaryFilterExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }