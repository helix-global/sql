using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCubeGroupByItem))]
    internal sealed class SqlScriptCubeGroupByItem : SqlScriptGroupingSetItem<SqlCubeGroupByItem>
        {
        #region ctor{IServiceProvider,SqlCubeGroupByItem}
        public SqlScriptCubeGroupByItem(IServiceProvider context,SqlCubeGroupByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }