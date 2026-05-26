using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDropStatement<T> : SqlScriptDdlStatement<T>
        where T : SqlDropStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDropStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }