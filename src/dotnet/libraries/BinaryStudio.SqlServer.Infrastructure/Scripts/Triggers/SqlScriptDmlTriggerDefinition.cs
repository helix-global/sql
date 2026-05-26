using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlDmlTriggerDefinition))]
    internal sealed class SqlScriptDmlTriggerDefinition : SqlScriptTriggerDefinition<SqlDmlTriggerDefinition>
        {
        public SqlObjectIdentifier QualifiedName { get; }
        [UsedImplicitly][Field] public override SqlObjectIdentifier TargetName { get; }

        #region ctor{IServiceProvider,SqlDmlTriggerDefinition}
        public SqlScriptDmlTriggerDefinition(IServiceProvider context,SqlDmlTriggerDefinition source)
            : base(context,source)
            {
            if (TargetName.SchemaName.Equals(SqlIdentifier.Null)) { TargetName = "dbo" + TargetName; }
            QualifiedName = TargetName + Name;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{QualifiedName}";
            }
        #endregion
        }
    }