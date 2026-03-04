using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDropSecurityPolicyStatement : SqlScriptDropStatement<SqlDropSecurityPolicyStatement>
        {
        #region ctor{IServiceProvider,SqlDropSecurityPolicyStatement}
        public SqlScriptDropSecurityPolicyStatement(IServiceProvider context,SqlDropSecurityPolicyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }