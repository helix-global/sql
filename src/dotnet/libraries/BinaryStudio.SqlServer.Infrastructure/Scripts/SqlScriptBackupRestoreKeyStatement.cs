using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptBackupRestoreKeyStatement<T> : SqlScriptStatement<T>
        where T : SqlBackupRestoreKeyStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreKeyStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }