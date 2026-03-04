using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptRestoreTableStatement : SqlScriptBackupRestoreTableStatement<SqlRestoreTableStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreTableStatement}
        public SqlScriptRestoreTableStatement(IServiceProvider context,SqlRestoreTableStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }