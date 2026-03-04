using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptDdlStatement<T> : SqlScriptStatement<T>
        where T: SqlDdlStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptDdlStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }