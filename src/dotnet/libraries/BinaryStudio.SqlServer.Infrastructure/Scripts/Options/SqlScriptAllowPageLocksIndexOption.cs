using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlAllowPageLocksIndexOption))]
    internal sealed class SqlScriptAllowPageLocksIndexOption : SqlScriptIndexOption<SqlAllowPageLocksIndexOption>
        {
        #region ctor{IServiceProvider,SqlAllowPageLocksIndexOption}
        public SqlScriptAllowPageLocksIndexOption(IServiceProvider context,SqlAllowPageLocksIndexOption source)
            : base(context, source)
            {
            }
        #endregion
        }
    }