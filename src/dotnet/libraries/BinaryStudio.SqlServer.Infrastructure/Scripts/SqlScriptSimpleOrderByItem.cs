using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlSimpleOrderByItem))]
    internal sealed class SqlScriptSimpleOrderByItem : SqlScriptCodeObject<SqlSimpleOrderByItem>
        {
        [UsedImplicitly][Field] public SqlSortOrder SortOrder { get; }

        #region ctor{IServiceProvider,SqlSimpleOrderByItem}
        public SqlScriptSimpleOrderByItem(IServiceProvider context,SqlSimpleOrderByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }