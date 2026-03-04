using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBackupTableStatement))]
    internal sealed class SqlScriptBackupTableStatement : SqlScriptBackupRestoreTableStatement<SqlBackupTableStatement>
        {
        #region ctor{IServiceProvider,SqlBackupTableStatement}
        public SqlScriptBackupTableStatement(IServiceProvider context,SqlBackupTableStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }