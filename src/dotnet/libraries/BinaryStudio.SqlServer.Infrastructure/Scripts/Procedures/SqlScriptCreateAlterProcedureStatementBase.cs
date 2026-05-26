using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptCreateAlterProcedureStatementBase<T> : SqlScriptDdlStatement<T>,ISqlProcedure
        where T : SqlCreateAlterProcedureStatementBase
        {
        [UsedImplicitly][Field] public ISqlScriptProcedureDefinition Definition { get; }
        SqlObjectIdentifier ISqlProcedure.Name { get { return Definition.Name; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterProcedureStatementBase(IServiceProvider context,T source)
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