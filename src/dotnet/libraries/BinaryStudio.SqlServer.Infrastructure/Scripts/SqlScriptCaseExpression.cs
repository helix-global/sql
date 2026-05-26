using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCaseExpression<T> : SqlScriptScalarExpression<T>
        where T : SqlCaseExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCaseExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }