using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreDatabaseStatement<T> : SqlScriptBackupRestoreStatement<T>
        where T : SqlBackupRestoreStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreDatabaseStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }