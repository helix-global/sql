using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDropRuleStatement))]
    internal sealed class SqlScriptDropRuleStatement : SqlScriptDropStatement<SqlDropRuleStatement>
        {
        #region ctor{IServiceProvider,SqlDropRuleStatement}
        public SqlScriptDropRuleStatement(IServiceProvider context,SqlDropRuleStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }