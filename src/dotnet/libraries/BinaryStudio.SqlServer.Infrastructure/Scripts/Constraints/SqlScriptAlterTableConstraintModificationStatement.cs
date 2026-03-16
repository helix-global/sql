using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(AlterTableConstraintModificationStatement))]
    internal sealed class SqlFragmentAlterTableConstraintModificationStatement : SqlFragmentAlterTableStatement<AlterTableConstraintModificationStatement>
        {
        #region ctor{IServiceProvider,AlterTableConstraintModificationStatement}
        public SqlFragmentAlterTableConstraintModificationStatement(IServiceProvider context,AlterTableConstraintModificationStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }