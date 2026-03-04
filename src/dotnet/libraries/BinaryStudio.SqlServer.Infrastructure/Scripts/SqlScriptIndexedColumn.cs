using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptIndexedColumn : SqlScriptCodeObject<SqlIndexedColumn>
        {
        public SqlSortOrder SortOrder {get{ return Source.SortOrder; }}

        #region ctor{IServiceProvider,SqlIndexedColumn}
        public SqlScriptIndexedColumn(IServiceProvider context,SqlIndexedColumn source)
            : base(context,source)
            {
            }
        #endregion
        }
    }