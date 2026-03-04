using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptUdtStaticMemberExpression<T> : SqlScriptUdtMemberExpression<T>
        where T : SqlUdtStaticMemberExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptUdtStaticMemberExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }