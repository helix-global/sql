using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptBackupDatabaseStatement : SqlScriptBackupRestoreDatabaseStatement<SqlBackupDatabaseStatement>
        {
        #region ctor{IServiceProvider,SqlBackupDatabaseStatement}
        public SqlScriptBackupDatabaseStatement(IServiceProvider context,SqlBackupDatabaseStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }