using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateUserWithImplicitAuthenticationStatement : SqlScriptCreateUserStatement<SqlCreateUserWithImplicitAuthenticationStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserWithImplicitAuthenticationStatement}
        public SqlScriptCreateUserWithImplicitAuthenticationStatement(IServiceProvider context,SqlCreateUserWithImplicitAuthenticationStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }