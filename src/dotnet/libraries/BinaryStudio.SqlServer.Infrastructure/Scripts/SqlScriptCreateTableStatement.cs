using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateTableStatement))]
    internal sealed class SqlScriptCreateTableStatement : SqlScriptDdlStatement<SqlCreateTableStatement>
        {
        [UsedImplicitly][Field] public SqlScriptTableDefinition Definition { get; }
        [UsedImplicitly][Field] public SqlScriptLargeDataStorageInformation LargeDataStorageInformation { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier Name { get; }
        [UsedImplicitly][Field] public SqlScriptStorageSpecification StorageSpecification { get; }

        #region ctor{IServiceProvider,SqlCreateTableStatement}
        public SqlScriptCreateTableStatement(IServiceProvider context,SqlCreateTableStatement source)
            : base(context,source)
            {
            return;
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