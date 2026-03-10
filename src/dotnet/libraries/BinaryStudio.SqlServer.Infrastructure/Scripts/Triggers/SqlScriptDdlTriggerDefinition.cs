using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDdlTriggerDefinition))]
    internal sealed class SqlScriptDdlTriggerDefinition : SqlScriptTriggerDefinition<SqlDdlTriggerDefinition>
        {
        #region ctor{IServiceProvider,SqlDdlTriggerDefinition}
        public SqlScriptDdlTriggerDefinition(IServiceProvider context,SqlDdlTriggerDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }