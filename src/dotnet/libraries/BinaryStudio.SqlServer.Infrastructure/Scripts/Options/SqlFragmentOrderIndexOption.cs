using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(OrderIndexOption))]
    internal sealed class SqlFragmentOrderIndexOption : SqlFragmentIndexOption<OrderIndexOption>
        {
        #region ctor{IServiceProvider,OrderIndexOption}
        public SqlFragmentOrderIndexOption(IServiceProvider context,OrderIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }