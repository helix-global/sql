using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptConditionClause<T> : SqlScriptCodeObject<T>
        where T : SqlConditionClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptConditionClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }