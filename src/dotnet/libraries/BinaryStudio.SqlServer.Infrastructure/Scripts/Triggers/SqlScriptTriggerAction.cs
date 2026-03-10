using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlTriggerAction))]
    internal sealed class SqlScriptTriggerAction : SqlScriptCodeObject<SqlTriggerAction>
        {
        public SqlTriggerActionType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,SqlTriggerAction}
        public SqlScriptTriggerAction(IServiceProvider context,SqlTriggerAction source)
            : base(context,source)
            {
            }
        #endregion
        }
    }