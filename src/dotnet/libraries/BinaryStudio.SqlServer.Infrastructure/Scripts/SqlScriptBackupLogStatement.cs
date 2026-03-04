using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBackupLogStatement))]
    internal sealed class SqlScriptBackupLogStatement : SqlScriptBackupRestoreLogStatement<SqlBackupLogStatement>
        {
        #region ctor{IServiceProvider,SqlBackupLogStatement}
        public SqlScriptBackupLogStatement(IServiceProvider context,SqlBackupLogStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }