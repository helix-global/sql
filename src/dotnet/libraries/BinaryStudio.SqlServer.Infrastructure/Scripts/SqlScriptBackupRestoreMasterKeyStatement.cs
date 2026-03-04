using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreMasterKeyStatement<T> : SqlScriptBackupRestoreKeyStatement<T>
        where T: SqlBackupRestoreMasterKeyStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreMasterKeyStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }