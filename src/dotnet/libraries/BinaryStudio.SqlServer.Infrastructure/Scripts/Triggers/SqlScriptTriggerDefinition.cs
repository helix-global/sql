using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptTriggerDefinition<T> : SqlScriptCodeObject<T>,ISqlScriptTriggerDefinition
        where T : SqlTriggerDefinition
        {
        public virtual SqlObjectIdentifier TargetName { get { return null; }}
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptTriggerDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }
    }