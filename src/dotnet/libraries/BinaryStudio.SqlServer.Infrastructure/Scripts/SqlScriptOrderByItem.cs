using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlOrderByItem))]
    internal sealed class SqlScriptOrderByItem : SqlScriptCodeObject<SqlOrderByItem>
        {
        [UsedImplicitly][Field] public SqlSortOrder SortOrder { get; }

        #region ctor{IServiceProvider,SqlOrderByItem}
        public SqlScriptOrderByItem(IServiceProvider context,SqlOrderByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }