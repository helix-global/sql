using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlAllowRowLocksIndexOption))]
    internal sealed class SqlScriptAllowRowLocksIndexOption : SqlScriptOnOffIndexOption<SqlAllowRowLocksIndexOption>
        {
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.AllowRowLocks; }}

        #region ctor{IServiceProvider,SqlAllowRowLocksIndexOption}
        public SqlScriptAllowRowLocksIndexOption(IServiceProvider context,SqlAllowRowLocksIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }