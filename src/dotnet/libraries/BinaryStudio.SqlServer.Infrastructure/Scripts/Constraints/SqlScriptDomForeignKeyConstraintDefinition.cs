using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(ForeignKeyConstraintDefinition))]
    internal sealed class SqlScriptDomForeignKeyConstraintDefinition : SqlScriptDomConstraintDefinition<ForeignKeyConstraintDefinition>
        {
        [UsedImplicitly][Field] public IList<SqlIdentifier> Columns { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction DeleteAction { get; }
        [UsedImplicitly][Field] public Boolean NotForReplication { get; }
        [UsedImplicitly][Field(Source="ReferencedTableColumns")] public IList<SqlIdentifier> ReferencedColumns { get; }
        [UsedImplicitly][Field(Source="ReferenceTableName")] public SqlObjectIdentifier ReferencedTable { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction UpdateAction { get; }

        #region ctor{IServiceProvider,ForeignKeyConstraintDefinition}
        public SqlScriptDomForeignKeyConstraintDefinition(IServiceProvider context,ForeignKeyConstraintDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }
