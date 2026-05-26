using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreTableStatement<T> : SqlScriptBackupRestoreStatement<T>
        where T : SqlBackupRestoreTableStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreTableStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }