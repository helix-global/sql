using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(AlterTableDropTableElementStatement))]
    internal sealed class SqlFragmentAlterTableDropTableElementStatement : SqlFragmentAlterTableStatement<AlterTableDropTableElementStatement>
        {
        #region ctor{IServiceProvider,AlterTableDropTableElementStatement}
        public SqlFragmentAlterTableDropTableElementStatement(IServiceProvider context,AlterTableDropTableElementStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }