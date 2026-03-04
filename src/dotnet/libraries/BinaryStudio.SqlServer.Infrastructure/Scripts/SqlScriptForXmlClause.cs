using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptForXmlClause<T> : SqlScriptForClause<T>
        where T : SqlForXmlClause
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptForXmlClause(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }