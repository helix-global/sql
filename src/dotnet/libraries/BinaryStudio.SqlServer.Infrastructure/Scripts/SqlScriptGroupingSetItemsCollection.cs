using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGroupingSetItemsCollection))]
    internal sealed class SqlScriptGroupingSetItemsCollection : SqlScriptGroupingSet<SqlGroupingSetItemsCollection>
        {
        #region ctor{IServiceProvider,SqlGroupingSetItemsCollection}
        public SqlScriptGroupingSetItemsCollection(IServiceProvider context,SqlGroupingSetItemsCollection source)
            : base(context,source)
            {
            }
        #endregion
        }
    }