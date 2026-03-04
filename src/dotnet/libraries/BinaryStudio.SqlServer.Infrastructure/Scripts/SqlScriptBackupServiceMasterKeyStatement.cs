using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptBackupServiceMasterKeyStatement : SqlScriptBackupRestoreServiceMasterKeyStatement<SqlBackupServiceMasterKeyStatement>
        {
        #region ctor{IServiceProvider,SqlBackupServiceMasterKeyStatement}
        public SqlScriptBackupServiceMasterKeyStatement(IServiceProvider context,SqlBackupServiceMasterKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }