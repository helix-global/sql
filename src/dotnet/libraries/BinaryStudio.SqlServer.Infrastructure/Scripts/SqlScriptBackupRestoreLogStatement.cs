using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreLogStatement<T> : SqlScriptBackupRestoreStatement<T>
        where T : SqlBackupRestoreLogStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreLogStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }