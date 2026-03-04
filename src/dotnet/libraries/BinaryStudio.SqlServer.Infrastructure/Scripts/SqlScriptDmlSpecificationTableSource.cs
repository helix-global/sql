using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
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