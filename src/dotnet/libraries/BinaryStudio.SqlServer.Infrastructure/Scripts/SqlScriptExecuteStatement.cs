using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptExecuteStatement<T> : SqlScriptStatement<T>
        where T: SqlExecuteStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptExecuteStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }