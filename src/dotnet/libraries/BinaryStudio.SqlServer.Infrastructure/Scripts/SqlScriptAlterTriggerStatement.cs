using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptAlterTriggerStatement : SqlScriptCreateAlterTriggerStatementBase<SqlAlterTriggerStatement>
        {
        #region ctor{IServiceProvider,SqlAlterTriggerStatement}
        public SqlScriptAlterTriggerStatement(IServiceProvider context,SqlAlterTriggerStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }