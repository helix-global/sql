using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlSetAssignmentStatement))]
    internal sealed class SqlScriptSetAssignmentStatement : SqlScriptSetStatement<SqlSetAssignmentStatement>
        {
        #region ctor{IServiceProvider,SqlSetAssignmentStatement}
        public SqlScriptSetAssignmentStatement(IServiceProvider context,SqlSetAssignmentStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }