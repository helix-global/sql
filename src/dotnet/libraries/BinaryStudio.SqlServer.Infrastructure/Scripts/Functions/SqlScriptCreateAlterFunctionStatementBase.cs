using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptCreateAlterFunctionStatementBase<T> : SqlScriptDdlStatement<T>,ISqlFunction
        where T : SqlCreateAlterFunctionStatementBase
        {
        [UsedImplicitly][Field] public ISqlScriptFunctionDefinition Definition { get; }
        SqlObjectIdentifier ISqlFunction.Name { get { return Definition.Name; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterFunctionStatementBase(IServiceProvider context,T source)
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