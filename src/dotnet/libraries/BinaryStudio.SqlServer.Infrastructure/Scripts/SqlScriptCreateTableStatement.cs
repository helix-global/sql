using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using FieldAttribute=BinaryStudio.SqlServer.Infrastructure.SqlModelFieldMappingAttribute;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateTableStatement))]
    internal sealed class SqlScriptCreateTableStatement : SqlScriptDdlStatement<SqlCreateTableStatement>
        {
        [Field][UsedImplicitly] public SqlScriptTableDefinition Definition { get; }
        [Field][UsedImplicitly] public SqlScriptLargeDataStorageInformation LargeDataStorageInformation { get; }
        [Field][UsedImplicitly] public SqlObjectIdentifier Name { get; }
        [Field][UsedImplicitly] public SqlScriptStorageSpecification StorageSpecification { get; }

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