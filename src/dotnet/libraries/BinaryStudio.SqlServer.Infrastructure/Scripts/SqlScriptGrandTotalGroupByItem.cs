using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGrandTotalGroupByItem))]
    internal sealed class SqlScriptGrandTotalGroupByItem : SqlScriptGroupByItem<SqlGrandTotalGroupByItem>
        {
        #region ctor{IServiceProvider,SqlGrandTotalGroupByItem}
        public SqlScriptGrandTotalGroupByItem(IServiceProvider context,SqlGrandTotalGroupByItem source)
            : base(context,source)
            {
            }
        #endregion
        }
    }