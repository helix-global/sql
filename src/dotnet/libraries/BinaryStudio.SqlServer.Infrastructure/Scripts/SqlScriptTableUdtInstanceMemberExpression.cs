using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptTableUdtInstanceMemberExpression<T> : SqlScriptTableUdtMemberExpression<T>
        where T: SqlTableUdtInstanceMemberExpression
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptTableUdtInstanceMemberExpression(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }