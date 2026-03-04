using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
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