using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDropTriggerStatement))]
    internal sealed class SqlScriptDropTriggerStatement : SqlScriptDropStatement<SqlDropTriggerStatement>
        {
        #region ctor{IServiceProvider,SqlDropTriggerStatement}
        public SqlScriptDropTriggerStatement(IServiceProvider context,SqlDropTriggerStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }