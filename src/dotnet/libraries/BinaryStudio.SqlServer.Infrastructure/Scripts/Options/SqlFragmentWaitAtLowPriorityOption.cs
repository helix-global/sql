using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(WaitAtLowPriorityOption))]
    internal sealed class SqlFragmentWaitAtLowPriorityOption : SqlFragmentIndexOption<WaitAtLowPriorityOption>
        {
        #region ctor{IServiceProvider,WaitAtLowPriorityOption}
        public SqlFragmentWaitAtLowPriorityOption(IServiceProvider context,WaitAtLowPriorityOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }