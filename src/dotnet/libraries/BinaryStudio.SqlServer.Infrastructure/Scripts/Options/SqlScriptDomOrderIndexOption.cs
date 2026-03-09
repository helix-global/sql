using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OrderIndexOption))]
    internal sealed class SqlScriptDomOrderIndexOption : SqlScriptDomIndexOption<OrderIndexOption>
        {
        #region ctor{IServiceProvider,OrderIndexOption}
        public SqlScriptDomOrderIndexOption(IServiceProvider context,OrderIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }