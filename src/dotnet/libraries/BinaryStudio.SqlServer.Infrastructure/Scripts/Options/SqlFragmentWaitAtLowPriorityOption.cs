using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(WaitAtLowPriorityOption))]
    internal sealed class SqlScriptDomWaitAtLowPriorityOption : SqlScriptDomIndexOption<WaitAtLowPriorityOption>
        {
        #region ctor{IServiceProvider,WaitAtLowPriorityOption}
        public SqlScriptDomWaitAtLowPriorityOption(IServiceProvider context,WaitAtLowPriorityOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }