using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptFunctionDefinition<T> : SqlScriptCodeObject<T>,ISqlScriptFunctionDefinition
        where T : SqlFunctionDefinition
        {
        [UsedImplicitly][Field] public SqlObjectIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptFunctionDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            if (Name.SchemaName.Equals(SqlIdentifier.Null)) { Name = "dbo" + Name; }
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