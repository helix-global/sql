using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCreateAlterTriggerStatementBase<T> : SqlScriptDdlStatement<T>
        where T : SqlCreateAlterTriggerStatementBase
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterTriggerStatementBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }