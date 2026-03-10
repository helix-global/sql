using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCreateAlterFunctionStatementBase<T> : SqlScriptDdlStatement<T>
        where T : SqlCreateAlterFunctionStatementBase
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterFunctionStatementBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }