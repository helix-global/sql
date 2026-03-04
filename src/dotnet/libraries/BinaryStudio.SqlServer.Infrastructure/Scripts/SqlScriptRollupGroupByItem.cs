using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlRollupGroupByItem))]
    internal sealed class SqlScriptRollupGroupByItem : SqlScriptGroupingSetItem<SqlRollupGroupByItem>
        {
        #region ctor{IServiceProvider,SqlRollupGroupByItem}
        public SqlScriptRollupGroupByItem(IServiceProvider context,SqlRollupGroupByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }