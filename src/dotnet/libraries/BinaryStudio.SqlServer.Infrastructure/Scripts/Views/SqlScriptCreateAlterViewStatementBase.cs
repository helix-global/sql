using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptCreateAlterViewStatementBase<T>: SqlScriptDdlStatement<T>
        where T : SqlCreateAlterViewStatementBase
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterViewStatementBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }