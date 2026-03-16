using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropAggregateStatement))]
    internal sealed class SqlScriptDropAggregateStatement : SqlScriptDropStatement<SqlDropAggregateStatement>
        {
        #region ctor{IServiceProvider,SqlDropAggregateStatement}
        public SqlScriptDropAggregateStatement(IServiceProvider context,SqlDropAggregateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }