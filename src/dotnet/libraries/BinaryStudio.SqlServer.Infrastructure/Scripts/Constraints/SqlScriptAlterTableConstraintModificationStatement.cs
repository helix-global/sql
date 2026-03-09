using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(AlterTableConstraintModificationStatement))]
    internal sealed class SqlScriptAlterTableConstraintModificationStatement : SqlScriptAlterTableStatement<AlterTableConstraintModificationStatement>
        {
        #region ctor{IServiceProvider,AlterTableConstraintModificationStatement}
        public SqlScriptAlterTableConstraintModificationStatement(IServiceProvider context,AlterTableConstraintModificationStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }