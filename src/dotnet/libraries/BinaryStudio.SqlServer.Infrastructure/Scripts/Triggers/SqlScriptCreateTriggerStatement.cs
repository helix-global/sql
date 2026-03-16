using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateTriggerStatement))]
    internal sealed class SqlScriptCreateTriggerStatement : SqlScriptCreateAlterTriggerStatementBase<SqlCreateTriggerStatement>
        {
        #region ctor{IServiceProvider,SqlCreateTriggerStatement}
        public SqlScriptCreateTriggerStatement(IServiceProvider context,SqlCreateTriggerStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }