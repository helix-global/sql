using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBinaryScalarExpression))]
    internal sealed class SqlScriptBinaryScalarExpression : SqlScriptScalarExpression<SqlBinaryScalarExpression>
        {
        #region ctor{IServiceProvider,SqlBinaryScalarExpression}
        public SqlScriptBinaryScalarExpression(IServiceProvider context,SqlBinaryScalarExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }