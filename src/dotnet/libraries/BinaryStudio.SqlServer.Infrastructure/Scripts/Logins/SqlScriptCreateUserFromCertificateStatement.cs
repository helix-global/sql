using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateUserFromCertificateStatement))]
    internal sealed class SqlScriptCreateUserFromCertificateStatement : SqlScriptCreateUserStatement<SqlCreateUserFromCertificateStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserFromCertificateStatement}
        public SqlScriptCreateUserFromCertificateStatement(IServiceProvider context,SqlCreateUserFromCertificateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }