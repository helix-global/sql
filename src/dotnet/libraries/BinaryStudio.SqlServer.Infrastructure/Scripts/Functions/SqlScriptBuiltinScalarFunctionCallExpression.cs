using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBuiltinScalarFunctionCallExpression<T> : SqlScriptScalarFunctionCallExpression<T>
        where T : SqlBuiltinScalarFunctionCallExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBuiltinScalarFunctionCallExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlBuiltinScalarFunctionCallExpression))]
    internal sealed class SqlScriptBuiltinScalarFunctionCallExpression : SqlScriptBuiltinScalarFunctionCallExpression<SqlBuiltinScalarFunctionCallExpression>
        {
        #region ctor{IServiceProvider,SqlBuiltinScalarFunctionCallExpression}
        public SqlScriptBuiltinScalarFunctionCallExpression(IServiceProvider context,SqlBuiltinScalarFunctionCallExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }