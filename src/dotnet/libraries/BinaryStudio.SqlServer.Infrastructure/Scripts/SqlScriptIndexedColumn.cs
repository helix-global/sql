using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlIndexedColumn))]
    internal sealed class SqlScriptIndexedColumn : SqlScriptCodeObject<SqlIndexedColumn>,ISqlScriptIndexedColumn
        {
        [UsedImplicitly][Field] public SqlSortOrder SortOrder { get; }
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }

        #region ctor{IServiceProvider,SqlIndexedColumn}
        public SqlScriptIndexedColumn(IServiceProvider context,SqlIndexedColumn source)
            : base(context,source)
            {
            }
        #endregion
        }
    }