using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptCreateOrAlterTriggerStatement<T> : SqlScriptDdlStatement<T>,ISqlTrigger
        where T : SqlCreateAlterTriggerStatementBase
        {
        [UsedImplicitly][Field] public ISqlScriptTriggerDefinition Definition { get; }
        public SqlIdentifier Name { get { return Definition.Name; }}
        public SqlObjectIdentifier TargetName { get { return Definition.TargetName; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateOrAlterTriggerStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Definition.Name.ToString();
            }
        #endregion
        }
    }