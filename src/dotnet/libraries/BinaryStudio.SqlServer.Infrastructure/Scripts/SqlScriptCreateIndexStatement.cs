using System;
using System.Collections.Generic;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [UsedImplicitly]
    [SqlScriptObject(typeof(SqlCreateIndexStatement))]
    internal sealed class SqlScriptCreateIndexStatement : SqlScriptDdlStatement<SqlCreateIndexStatement>
        {
        [SqlModelFieldMapping][UsedImplicitly] public Boolean IsUnique { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlIdentifier Name { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlObjectIdentifier TargetObject { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlClusterOption ClusterOption { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlScriptStorageSpecification FileStream { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlScriptStorageSpecification StorageSpecification { get; }
        [SqlModelFieldMapping][UsedImplicitly] public SqlScriptFilterClause FilterClause { get; }
        [SqlModelFieldMapping(Source="IndexedColunms")][UsedImplicitly] public IList<SqlScriptIndexedColumn> IndexedColumns { get; }
        [SqlModelFieldMapping(EmptyIfNull = true)][UsedImplicitly] public IList<SqlIdentifier> IncludedColumns { get; }
        [SqlModelFieldMapping(EmptyIfNull = true)][UsedImplicitly] public IList<ISqlScriptIndexOption> Options { get; }

        #region ctor{IServiceProvider,SqlCreateIndexStatement}
        public SqlScriptCreateIndexStatement(IServiceProvider context,SqlCreateIndexStatement source)
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
            return $"{Name}";
            }
        #endregion
        }
    }