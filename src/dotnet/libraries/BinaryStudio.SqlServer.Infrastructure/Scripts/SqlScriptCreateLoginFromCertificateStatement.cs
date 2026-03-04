using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateLoginFromCertificateStatement))]
    internal sealed class SqlScriptCreateLoginFromCertificateStatement : SqlScriptCreateLoginStatement<SqlCreateLoginFromCertificateStatement>
        {
        #region ctor{IServiceProvider,SqlCreateLoginFromCertificateStatement}
        public SqlScriptCreateLoginFromCertificateStatement(IServiceProvider context,SqlCreateLoginFromCertificateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }