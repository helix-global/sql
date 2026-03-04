using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCreateAlterProcedureStatementBase<T> : SqlScriptDdlStatement<T>
        where T : SqlCreateAlterProcedureStatementBase
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterProcedureStatementBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }