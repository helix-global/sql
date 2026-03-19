using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ForeignKeyConstraintDefinition))]
    internal sealed class SqlFragmentForeignKeyConstraintDefinition : SqlFragmentConstraintDefinition<ForeignKeyConstraintDefinition>,ISqlForeignKeyConstraint
        {
        [UsedImplicitly][Field] public IList<SqlIdentifier> Columns { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction DeleteAction { get; }
        [UsedImplicitly][Field] public Boolean NotForReplication { get; }
        [UsedImplicitly][Field(Source="ReferencedTableColumns")] public IList<SqlIdentifier> ReferencedColumns { get; }
        [UsedImplicitly][Field(Source="ReferenceTableName")] public SqlObjectIdentifier ReferencedTable { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction UpdateAction { get; }
        public override SqlConstraintType Type { get{ return SqlConstraintType.ForeignKey; }}

        #region ctor{IServiceProvider,ForeignKeyConstraintDefinition}
        public SqlFragmentForeignKeyConstraintDefinition(IServiceProvider context,ForeignKeyConstraintDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }
