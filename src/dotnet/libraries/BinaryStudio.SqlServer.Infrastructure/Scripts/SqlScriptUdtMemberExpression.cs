using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptUdtMemberExpression<T> : SqlScriptScalarExpression<T>
        where T : SqlUdtMemberExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptUdtMemberExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }