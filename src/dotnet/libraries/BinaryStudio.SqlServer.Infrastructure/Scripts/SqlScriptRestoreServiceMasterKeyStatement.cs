using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptRestoreServiceMasterKeyStatement : SqlScriptBackupRestoreServiceMasterKeyStatement<SqlRestoreServiceMasterKeyStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreServiceMasterKeyStatement}
        public SqlScriptRestoreServiceMasterKeyStatement(IServiceProvider context,SqlRestoreServiceMasterKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }