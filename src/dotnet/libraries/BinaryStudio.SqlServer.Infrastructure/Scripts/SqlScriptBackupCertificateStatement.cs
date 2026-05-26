using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBackupCertificateStatement))]
    internal sealed class SqlScriptBackupCertificateStatement : SqlScriptStatement<SqlBackupCertificateStatement>
        {
        #region ctor{IServiceProvider,SqlBackupCertificateStatement}
        public SqlScriptBackupCertificateStatement(IServiceProvider context,SqlBackupCertificateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }