using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTriggerDefinitionError))]
    internal sealed class SqlScriptTriggerDefinitionError : SqlScriptTriggerDefinition<SqlTriggerDefinitionError>
        {
        public Boolean IsNotForReplication { get { return Source.IsNotForReplication; }}
        public Boolean IsWithAppend { get { return Source.IsWithAppend; }}
        public SqlDdlTriggerTargetType TargetType { get { return Source.TargetType; }}

        #region ctor{IServiceProvider,SqlTriggerDefinitionError}
        public SqlScriptTriggerDefinitionError(IServiceProvider context,SqlTriggerDefinitionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }