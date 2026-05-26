using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateTriggerStatement))]
    internal sealed class SqlScriptCreateTriggerStatement : SqlScriptCreateOrAlterTriggerStatement<SqlCreateTriggerStatement>
        {
        #region ctor{IServiceProvider,SqlCreateTriggerStatement}
        public SqlScriptCreateTriggerStatement(IServiceProvider context,SqlCreateTriggerStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }