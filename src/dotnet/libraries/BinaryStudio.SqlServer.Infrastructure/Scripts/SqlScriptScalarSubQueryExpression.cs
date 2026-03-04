using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptScalarSubQueryExpression : SqlScriptScalarExpression<SqlScalarSubQueryExpression>
        {
        #region ctor{IServiceProvider,SqlScalarSubQueryExpression}
        public SqlScriptScalarSubQueryExpression(IServiceProvider context,SqlScalarSubQueryExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }