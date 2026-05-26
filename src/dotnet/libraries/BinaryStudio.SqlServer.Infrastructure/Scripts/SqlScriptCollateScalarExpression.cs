using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCollateScalarExpression))]
    internal sealed class SqlScriptCollateScalarExpression : SqlScriptScalarExpression<SqlCollateScalarExpression>
        {
        #region ctor{IServiceProvider,SqlCollateScalarExpression}
        public SqlScriptCollateScalarExpression(IServiceProvider context,SqlCollateScalarExpression source)
            : base(context, source)
            {
            }
        #endregion
        }
    }