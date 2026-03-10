using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDmlTriggerDefinition))]
    internal sealed class SqlScriptDmlTriggerDefinition : SqlScriptTriggerDefinition<SqlDmlTriggerDefinition>
        {
        #region ctor{IServiceProvider,SqlDmlTriggerDefinition}
        public SqlScriptDmlTriggerDefinition(IServiceProvider context,SqlDmlTriggerDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }