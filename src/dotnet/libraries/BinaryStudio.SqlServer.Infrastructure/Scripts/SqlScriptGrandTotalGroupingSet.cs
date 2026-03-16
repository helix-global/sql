using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGrandTotalGroupingSet))]
    internal sealed class SqlScriptGrandTotalGroupingSet : SqlScriptGroupingSet<SqlGrandTotalGroupingSet>
        {
        #region ctor{IServiceProvider,SqlGrandTotalGroupingSet}
        public SqlScriptGrandTotalGroupingSet(IServiceProvider context,SqlGrandTotalGroupingSet source)
            : base(context,source)
            {
            }
        #endregion
        }
    }