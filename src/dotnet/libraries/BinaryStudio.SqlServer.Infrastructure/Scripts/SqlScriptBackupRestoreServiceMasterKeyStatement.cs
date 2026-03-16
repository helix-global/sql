using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptBackupRestoreServiceMasterKeyStatement<T> : SqlScriptBackupRestoreKeyStatement<T>
        where T : SqlBackupRestoreServiceMasterKeyStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptBackupRestoreServiceMasterKeyStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }