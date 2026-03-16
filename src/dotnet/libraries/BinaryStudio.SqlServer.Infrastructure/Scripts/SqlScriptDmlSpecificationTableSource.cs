using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDmlSpecificationTableSource))]
    internal sealed class SqlScriptDmlSpecificationTableSource : SqlScriptTableExpression<SqlDmlSpecificationTableSource>
        {
        #region ctor{IServiceProvider,SqlDmlSpecificationTableSource}
        public SqlScriptDmlSpecificationTableSource(IServiceProvider context,SqlDmlSpecificationTableSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }