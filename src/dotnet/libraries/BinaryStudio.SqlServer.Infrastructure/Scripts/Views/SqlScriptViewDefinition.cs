using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlViewDefinition))]
    internal sealed class SqlScriptViewDefinition : SqlScriptCodeObject<SqlViewDefinition>
        {
        [UsedImplicitly][Field] public Boolean HasCheckOption { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier Name { get; }

        #region ctor{IServiceProvider,SqlViewDefinition}
        public SqlScriptViewDefinition(IServiceProvider context,SqlViewDefinition source)
            : base(context,source)
            {
            if (Name.SchemaName.Equals(SqlIdentifier.Null)) {
                Name = "dbo" + Name;
                }
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