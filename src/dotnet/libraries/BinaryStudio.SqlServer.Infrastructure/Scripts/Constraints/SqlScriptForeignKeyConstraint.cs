using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlForeignKeyConstraint))]
    internal sealed class SqlScriptForeignKeyConstraint : SqlScriptConstraint<SqlForeignKeyConstraint>,ISqlForeignKeyConstraint
        {
        [UsedImplicitly][Field] public IList<SqlIdentifier> Columns { get; }
        [UsedImplicitly][Field] public IList<SqlIdentifier> ReferencedColumns { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction DeleteAction { get; }
        [UsedImplicitly][Field] public Boolean NotForReplication { get; }
        [UsedImplicitly][Field] public SqlObjectIdentifier ReferencedTable { get; }
        [UsedImplicitly][Field] public SqlForeignKeyAction UpdateAction { get; }

        #region ctor{IServiceProvider,SqlForeignKeyConstraint}
        public SqlScriptForeignKeyConstraint(IServiceProvider context,SqlForeignKeyConstraint source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }