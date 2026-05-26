using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptQueryExpression<T> : SqlScriptCodeObject<T>
        where T : SqlQueryExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptQueryExpression(IServiceProvider context,T source)
            : base(context, source)
            {
            }
        #endregion
        }
    }