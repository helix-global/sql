using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class SqlScriptCreateAlterViewStatementBase<T>: SqlScriptDdlStatement<T>
        where T : SqlCreateAlterViewStatementBase
        {
        [UsedImplicitly][Field] public SqlScriptViewDefinition Definition { get; }
        public SqlObjectIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateAlterViewStatementBase(IServiceProvider context,T source)
            : base(context,source)
            {
            Name = Definition.Name;
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