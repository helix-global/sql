using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlOrderByItem))]
    internal sealed class SqlScriptOrderByItem : SqlScriptCodeObject<SqlOrderByItem>
        {
        public SqlSortOrder SortOrder { get { return Source.SortOrder; }}

        #region ctor{IServiceProvider,SqlOrderByItem}
        public SqlScriptOrderByItem(IServiceProvider context,SqlOrderByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }