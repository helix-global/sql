using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptTableUdtMemberExpression<T> : SqlScriptTableExpression<T>
        where T : SqlTableUdtMemberExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptTableUdtMemberExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }