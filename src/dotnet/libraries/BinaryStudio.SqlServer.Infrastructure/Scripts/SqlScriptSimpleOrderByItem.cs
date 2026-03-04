using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSimpleOrderByItem : SqlScriptCodeObject<SqlSimpleOrderByItem>
        {
        public SqlSortOrder SortOrder { get { return Source.SortOrder; }}

        #region ctor{IServiceProvider,SqlSimpleOrderByItem}
        public SqlScriptSimpleOrderByItem(IServiceProvider context,SqlSimpleOrderByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }