using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlRestoreLogStatement))]
    internal sealed class SqlScriptRestoreLogStatement : SqlScriptBackupRestoreLogStatement<SqlRestoreLogStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreLogStatement}
        public SqlScriptRestoreLogStatement(IServiceProvider context,SqlRestoreLogStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }