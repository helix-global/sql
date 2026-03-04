using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateRoleStatement))]
    internal sealed class SqlScriptCreateRoleStatement : SqlScriptDdlStatement<SqlCreateRoleStatement>
        {
        #region ctor{IServiceProvider,SqlCreateRoleStatement}
        public SqlScriptCreateRoleStatement(IServiceProvider context,SqlCreateRoleStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }