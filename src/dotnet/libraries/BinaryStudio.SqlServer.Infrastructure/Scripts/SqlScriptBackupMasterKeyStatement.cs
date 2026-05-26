using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBackupMasterKeyStatement))]
    internal sealed class SqlScriptBackupMasterKeyStatement : SqlScriptBackupRestoreMasterKeyStatement<SqlBackupMasterKeyStatement>
        {
        #region ctor{IServiceProvider,SqlBackupMasterKeyStatement}
        public SqlScriptBackupMasterKeyStatement(IServiceProvider context,SqlBackupMasterKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }