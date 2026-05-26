using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OnlineIndexOption))]
    internal sealed class SqlFragmentOnlineIndexOption : SqlFragmentIndexStateOption<OnlineIndexOption>
        {
        #region ctor{IServiceProvider,OnlineIndexOption}
        public SqlFragmentOnlineIndexOption(IServiceProvider context,OnlineIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }