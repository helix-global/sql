using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptScalarFunctionCallExpression<T> : SqlScriptScalarExpression<T>
        where T : SqlScalarFunctionCallExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarFunctionCallExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }