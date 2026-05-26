using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlScalarRefExpression.SqlColumnOrPropertyRefExpression")]
    internal sealed class SqlScriptColumnOrPropertyRefExpression : SqlScriptScalarRefExpression<SqlScalarRefExpression>
        {
        #region ctor{IServiceProvider,SqlScalarRefExpression}
        public SqlScriptColumnOrPropertyRefExpression(IServiceProvider context,SqlScalarRefExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }