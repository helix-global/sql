using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [UsedImplicitly]
    [SqlScriptObject(typeof(SqlCreateIndexStatement))]
    internal sealed class SqlScriptCreateIndexStatement : SqlScriptDdlStatement<SqlCreateIndexStatement>,ISqlIndex
        {
        public SqlObjectIdentifier QualifiedName { get; }
        [UsedImplicitly][Field] public Boolean IsUnique { get; }
        [UsedImplicitly][Field] public SqlIdentifier Name { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier TargetObject { get; }
        [UsedImplicitly][Field] public SqlClusterOption ClusterOption { get; }
        [UsedImplicitly][Field] public SqlScriptStorageSpecification FileStream { get; }
        [UsedImplicitly][Field] public SqlScriptStorageSpecification StorageSpecification { get; }
        [UsedImplicitly][Field] public SqlScriptFilterClause FilterClause { get; }
        [UsedImplicitly][Field(Source="IndexedColunms")] public IList<SqlScriptIndexedColumn> IndexedColumns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<SqlIdentifier> IncludedColumns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptIndexOption> Options { get; }

        #region ctor{IServiceProvider,SqlCreateIndexStatement}
        public SqlScriptCreateIndexStatement(IServiceProvider context,SqlCreateIndexStatement source)
            : base(context,source)
            {
            if (TargetObject.SchemaName.Equals(SqlIdentifier.Null)) { TargetObject = "dbo" + TargetObject; }
            QualifiedName = TargetObject + Name;
            return;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return $"{QualifiedName}";
            }
        #endregion
        }
    }