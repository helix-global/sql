using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptScalarExpression<T> : SqlScriptCodeObject<T>,ISqlScriptScalarExpression
        where T : SqlScalarExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptScalarExpression(IServiceProvider context,T source)
            : base(context, source)
            {
            }
        #endregion
        }
    }