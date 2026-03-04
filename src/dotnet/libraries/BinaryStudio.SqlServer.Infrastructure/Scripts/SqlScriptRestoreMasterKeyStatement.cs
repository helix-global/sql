using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptRestoreMasterKeyStatement : SqlScriptBackupRestoreMasterKeyStatement<SqlRestoreMasterKeyStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreMasterKeyStatement}
        public SqlScriptRestoreMasterKeyStatement(IServiceProvider context,SqlRestoreMasterKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }