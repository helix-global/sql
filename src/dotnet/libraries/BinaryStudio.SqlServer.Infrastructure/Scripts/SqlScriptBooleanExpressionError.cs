using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBooleanExpressionError : SqlScriptBooleanExpression<SqlBooleanExpressionError>
        {
        #region ctor{IServiceProvider,SqlBooleanExpressionError}
        public SqlScriptBooleanExpressionError(IServiceProvider context,SqlBooleanExpressionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }