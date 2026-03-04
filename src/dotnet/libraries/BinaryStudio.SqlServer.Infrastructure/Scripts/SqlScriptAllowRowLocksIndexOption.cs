using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptAllowRowLocksIndexOption : SqlScriptIndexOption<SqlAllowRowLocksIndexOption>
        {
        #region ctor{IServiceProvider,SqlAllowRowLocksIndexOption}
        public SqlScriptAllowRowLocksIndexOption(IServiceProvider context,SqlAllowRowLocksIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }