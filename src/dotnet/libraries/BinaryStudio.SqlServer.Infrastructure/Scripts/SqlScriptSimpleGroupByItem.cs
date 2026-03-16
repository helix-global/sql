using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSimpleGroupByItem))]
    internal sealed class SqlScriptSimpleGroupByItem : SqlScriptGroupingSetItem<SqlSimpleGroupByItem>
        {
        #region ctor{IServiceProvider,SqlSimpleGroupByItem}
        public SqlScriptSimpleGroupByItem(IServiceProvider context,SqlSimpleGroupByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }