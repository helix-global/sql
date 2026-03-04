using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateLoginFromWindowsStatement : SqlScriptCreateLoginStatement<SqlCreateLoginFromWindowsStatement>
        {
        #region ctor{IServiceProvider,SqlCreateLoginFromWindowsStatement}
        public SqlScriptCreateLoginFromWindowsStatement(IServiceProvider context,SqlCreateLoginFromWindowsStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }