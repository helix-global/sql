using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(OnlineIndexOption))]
    internal sealed class SqlScriptDomOnlineIndexOption : SqlScriptDomIndexStateOption<OnlineIndexOption>
        {
        #region ctor{IServiceProvider,OnlineIndexOption}
        public SqlScriptDomOnlineIndexOption(IServiceProvider context,OnlineIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }