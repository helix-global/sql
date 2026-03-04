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
    }