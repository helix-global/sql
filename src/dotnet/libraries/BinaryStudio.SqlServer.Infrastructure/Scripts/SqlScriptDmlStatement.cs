using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDmlStatement<T> : SqlScriptStatement<T>
        where T : SqlDmlStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDmlStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }