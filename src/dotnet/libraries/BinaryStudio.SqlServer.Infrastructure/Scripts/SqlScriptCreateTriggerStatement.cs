using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
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