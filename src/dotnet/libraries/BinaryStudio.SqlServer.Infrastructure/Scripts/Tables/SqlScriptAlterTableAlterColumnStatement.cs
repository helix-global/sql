using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(AlterTableAlterColumnStatement))]
    internal sealed class SqlScriptAlterTableAlterColumnStatement : SqlScriptAlterTableStatement<AlterTableAlterColumnStatement>
        {
        #region ctor{IServiceProvider,AlterTableAlterColumnStatement}
        public SqlScriptAlterTableAlterColumnStatement(IServiceProvider context,AlterTableAlterColumnStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }