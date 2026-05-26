using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreStatement<T> : SqlScriptStatement<T>
        where T : SqlBackupRestoreStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }