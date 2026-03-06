using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(AlterTableDropTableElementStatement))]
    internal sealed class SqlScriptAlterTableDropTableElementStatement : SqlScriptAlterTableStatement<AlterTableDropTableElementStatement>
        {
        #region ctor{IServiceProvider,AlterTableDropTableElementStatement}
        public SqlScriptAlterTableDropTableElementStatement(IServiceProvider context,AlterTableDropTableElementStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }