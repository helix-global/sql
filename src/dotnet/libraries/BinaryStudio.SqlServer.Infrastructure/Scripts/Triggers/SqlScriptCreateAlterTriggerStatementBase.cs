using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptCreateAlterTriggerStatementBase<T> : SqlScriptDdlStatement<T>,ISqlTrigger
        where T : SqlCreateAlterTriggerStatementBase
        {
        [UsedImplicitly][Field] public ISqlScriptTriggerDefinition Definition { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterTriggerStatementBase(IServiceProvider context,T source)
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